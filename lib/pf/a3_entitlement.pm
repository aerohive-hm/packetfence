package pf::a3_entitlement;

=head1 NAME

pf::a3_entitlement Support functions for A3 entitlement

=head1 DESCRIPTION

Support functions for A3 entitlement

=cut

use strict;
use warnings;
use Readonly;

use POSIX qw(strftime);
use Date::Parse;

Readonly::Scalar our $KEY_STATUS_UNUSED   => 1;
Readonly::Scalar our $KEY_STATUS_ACTIVE   => 2;
Readonly::Scalar our $KEY_STATUS_INACTIVE => 3;

Readonly::Scalar our $TRIAL_KEY           => "TRIAL";
Readonly::Scalar our $TRIAL_TYPE          => "Trial";
Readonly::Scalar our $TRIAL_CAPACITY      => 100;

use pf::log;
use pf::error qw(is_success is_error);
use pf::config qw(%Config);
use pf::constants qw($TRUE $FALSE $A3_SYSTEM_ID $MAX_LICENSED_CAPACITY);
use pf::dal::a3_entitlement;
use pf::dal::a3_daily_avg;
use JSON;
use WWW::Curl::Easy;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA    = qw(Exporter);
    @EXPORT = qw(is_usage_under_capacity is_entitlement_expired get_trial_status);
}

=head2 find_one

Finds a single entitlement key applied to the current system

=cut

sub find_one {
    my ( $key ) = @_;

    my ( $status, $dal ) = pf::dal::a3_entitlement->find({entitlement_key => $key});

    return is_success($status) ? $dal : $FALSE;
}


=head2 is_usage_under_capacity

compares the current endpoints moving avg with allowed capacity

=cut

sub is_usage_under_capacity {
    my $logger = get_logger();
    #TODO, Move the get_licensed_capacity sub from Model/Entitlement here
    my $total = 0;

    foreach my $entitlement (find_active()) {
        $total += $entitlement->{endpoint_count};
    }

    if ($total == 0) {
        my $all_entitlements = find_all();
        my ($trial_status, $trial_info) = get_trial_status();

        if (@$all_entitlements == 0 && $trial_info) {
            if (time() < str2time($trial_info->{sub_end})) {
                $total = $trial_info->{endpoint_count};
            }
        }
    }
    #if licensed capacity exceeds 100k, we don't check for usage limit
    return $TRUE if $total >= $MAX_LICENSED_CAPACITY;

    my ($count_status, $count) = get_current_moving_avg_count();
    if (is_success($count_status)) {
        #return true if we only have less than 7 days of moving avg
        return $TRUE if $count < 7;
    }
    else {
        $logger->warn("Cannot retrieve moving average count from db");
        #if system fault, we omit the usage check
        #TODO add the status check
        return $TRUE;
    }
    my ($status, $current_moving_avg) = get_current_moving_avg();
    if (is_success($status)) {
        return $current_moving_avg <= $total;
    }
    else {
        $logger->warn("Cannot retrieve moving average data from db");
        return $TRUE;
    }

}

=head2 get_trial_status

Checks whether the trial has expired

=cut

sub get_trial_status {
    my $trial = get_trial();
    if ($trial != $FALSE) {
        my $now = time();
        my $end = str2time($trial->{sub_end});

        if ($now < $end) {
            $trial->{is_expired} = $FALSE;
            $trial->{expires_in} = $end - $now;
        }
        else {
            $trial->{is_expired} = $TRUE;
        }
        return $STATUS::OK, $trial;
    }
    else {
        return $STATUS::NOT_FOUND;
    }
}

=head2 is_entitlment_expired

Checks whether the current entitlement is still active or not

=cut

sub is_entitlement_expired {
    my $logger = get_logger();
    my @active_entitlements = find_active();
    my ($trial_status, $trial_info) = get_trial_status();
    if (is_success($trial_status) && is_in_trial()) {
        return $trial_info->{is_expired} && @active_entitlements == 0;
    }
    else {
        return @active_entitlements == 0;
    }
}

=head2 get_current_moving_avg

Returns the current moving avg of daily usage samples

=cut

sub get_current_moving_avg {
    my $logger = get_logger();
    my ($status, $iter) = pf::dal::a3_daily_avg->search(
        -limit => 1,
        -order_by => {-desc => 'daily_date'},
    );
    my $current_avg = $iter->all;
    if (is_success($status)) {
        return $STATUS::OK, $current_avg->[0]->{moving_avg};

    }
    else {
        $logger->error("Failed to get current moving avg");
        return $STATUS::NOT_FOUND;
    }

}

=head2 get_current_moving_avg_count

Returns the number of daily moving avg samples

=cut

sub get_current_moving_avg_count {
    my $logger = get_logger();
    my ($status, $count) = pf::dal::a3_daily_avg->count();
    if (is_success($status)) {
        return $STATUS::OK, $count;
    }
    else {
        $logger->error("Failed to get the count of moving avg");
        return $STATUS::NOT_FOUND;
    }

}



=head2 find_all

Returns all of the entitlement keys applied to the current system

=cut

sub find_all {
    my $logger = get_logger();

    my ($status, $iter) = pf::dal::a3_entitlement->search(
        -where => {
            type => { "!=" => $TRIAL_TYPE },
        },
        -order_by => {-desc => 'sub_end'},
    );

    # Find all entitlement keys on this system
    if (is_success($status)) {
        return $iter->all;
    }
    else {
        $logger->error("Failed to list entitlement keys: $status");
        return $FALSE
    }
}

=head2 find_active

Returns entitlements that are currently active

=cut

sub find_active {
    my $logger = get_logger();

    my ($status, $iter) = pf::dal::a3_entitlement->search(
        -where => {
            type => { "!=" => $TRIAL_TYPE },
            status => $KEY_STATUS_ACTIVE,
            -and => [
                \['unix_timestamp(now()) >= unix_timestamp(sub_start)'],
                \['unix_timestamp(now()) <  unix_timestamp(sub_end)'],
            ]
        }
    );

    # Find all entitlement keys on this system
    if (is_success($status)) {
        return @{ $iter->all(undef) // [] };
    }
    else {
        $logger->error("Failed to list entitlement keys: $status");
        return ();
    }
}

=head2 create

Creates a new entitlement key record in the database

=cut

sub create {
    my ($key, $data) = @_;
    my $logger = get_logger();

    my $status = pf::dal::a3_entitlement->create({
        entitlement_key => $key,
        type            => $data->{keyType},
        status          => $data->{keyStatus},
        endpoint_count  => $data->{endpointCount},
        sub_start       => $data->{subStartDate}     . ' 00:00:00',
        sub_end         => $data->{subEndDate}       . ' 00:00:00',
        support_start   => $data->{supportStartDate} . ' 00:00:00',
        support_end     => $data->{supportEndDate}   . ' 00:00:00'
    });

    if (is_success($status)) {
        $logger->info("Added entitlement key $key ($data->{endpointCount}) to database");
    }
    else {
        $logger->error("Failed to add entitlement key $key to database");
    }

    return $status;
}

=head2 create_trial

Creates a new trial entitlement record in the database

=cut

sub create_trial {
    my $logger = get_logger();

    my $now = time();
    my $end = $now + 30 * 24 * 60 * 60;

    my $start  = strftime( "%Y-%m-%d %H:%M:%S", gmtime($now) );
    my $expire = strftime( "%Y-%m-%d %H:%M:%S", gmtime($end) );

    my $status = pf::dal::a3_entitlement->create({
        entitlement_key => $TRIAL_KEY,
        type            => $TRIAL_TYPE,
        status          => $KEY_STATUS_ACTIVE,
        endpoint_count  => $TRIAL_CAPACITY,
        sub_start       => $start,
        sub_end         => $expire,
        support_start   => $start,
        support_end     => $expire
    });

    if (is_success($status)) {
        $logger->info("Added trial key to database for $TRIAL_CAPACITY endpoints expiring at $expire");
    }
    else {
        $logger->error("Failed to add trial key to database");
    }

    return $status;
}

=head2 get_trial

=cut

sub get_trial {
    return find_one($TRIAL_KEY);
}

=head2 is_in_trial

checks whether the user is in trial or not, in trial means no entitlement keys found and the trial key is found

=cut

sub is_in_trial {
    my $logger = get_logger();
    my $all_entitlements = find_all();
    if (!@$all_entitlements){
      $logger->info("TRUE: !find_all");
    }else{
        $logger->info("FALSE find_all");
    }
    return !@$all_entitlements && get_trial();
}

=head2 verify

Sends an entitlement key to ACS for validation

=cut

sub verify {
    my ($key) = @_;
    my $logger = get_logger();

    my $acs_entitlement_url = "$Config{A3}->{license_server}$Config{A3}->{entitlement_path}";

    my $curl = WWW::Curl::Easy->new;

    $curl->setopt(CURLOPT_POST, 1);
    $curl->setopt(CURLOPT_URL, $acs_entitlement_url);

    if ($Config{A3}->{license_username} && $Config{A3}->{license_password}) {
        $curl->setopt(CURLOPT_USERNAME, $Config{A3}->{license_username});
        $curl->setopt(CURLOPT_PASSWORD, $Config{A3}->{license_password});
    }

    $curl->setopt(CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);

    my $json = JSON->new->allow_nonref;

    my %request = (
        systemId => $A3_SYSTEM_ID,
        key      => $key
    );

    $curl->setopt(CURLOPT_POSTFIELDS, $json->encode(\%request));

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    my $retcode = $curl->perform;

    if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);

        $logger->info("response $response_code: $response_body");

        if (is_success($response_code)) {
            return $json->decode($response_body);
        }
        else {
            return { err_status => $response_code };
        }
    }
    else {
        $logger->error("Failed to contact ACS to validate entitlement key: retcode = $retcode");
    }

    return $FALSE;
}

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
