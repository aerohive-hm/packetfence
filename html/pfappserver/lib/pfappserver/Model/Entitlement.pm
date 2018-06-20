package pfappserver::Model::Entitlement;

=head1 NAME

pfappserver::Model::Entitlement - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Date::Parse;

use Moose;

use pf::log;
use pf::error qw(is_success is_error);
use pf::constants qw($TRUE $FALSE);
use pf::a3_entitlement;
use pf::accounting;
use pf::node;

extends 'Catalyst::Model';

=head1 METHODS

=head2 list

Retrieve the list of entitlement keys currently installed on this system.

=cut

sub list_entitlement_keys {
    # return pf::a3_entitlement::find_all();
    my $entitlements = pf::a3_entitlement::find_all();

    if($entitlements) {
        my $now = time();

        foreach my $key (@$entitlements) {
            my $start = str2time($key->{sub_start});
            my $end   = str2time($key->{sub_end});

            if ($now < $start || $now > $end) {
                $key->{lic_status} = "notValidExpired"
            } elsif (($end - $now) <= 30 * 24 * 60 * 60) {
                $key->{lic_status} = "expiringSoon"
            } elsif ($key->{status} == $pf::a3_entitlement::KEY_STATUS_INACTIVE) {
                $key->{lic_status} = "deactivated"
            } else {
                $key->{lic_status} = "";
            }
            $key->{expires_in} = int((($end - $now) / 86400));
        }
    }
    return $entitlements;
}


=head2 apply

Apply a new entitlement key to this system.

=cut

sub apply_entitlement_key {
    my ( $self, $key ) = @_;
    my $logger = get_logger();

    $logger->info("Validating entitlement key $key...");

    # Send key to Aerohive to validate
    my $responseHash = pf::a3_entitlement::verify($key);

    if ($responseHash) {
        if ($responseHash->{err_status}) {
            $logger->warn("Got error response ($responseHash->{err_status}) for $key");
            return $responseHash;
        }
        else {
            # On success, save entitlement properties and return object
            if (pf::a3_entitlement::create($key, $responseHash)) {
                $logger->info("Total capacity is now " . $self->get_licensed_capacity());
                return pf::a3_entitlement::find_one($key);
            }
        }
    }

    return undef;
}

=head2 get

Find a specific entitlement key.

=cut

sub get_entitlement_key {
    my ( $self, $key ) = @_;

    return pf::a3_entitlement::find_one($key);
}

=head2 get_licensed_capacity

Get the total licensed endpoint capacity from active entitlements

=cut

sub get_licensed_capacity {
    my $total = 0;

    foreach my $entitlement (pf::a3_entitlement::find_active()) {
        $total += $entitlement->{endpoint_count};
    }

    if ($total == 0) {
        my $all_entitlements = pf::a3_entitlement::find_all();
        my ($trial_status, $trial_info) = get_trial_info();

        if (@$all_entitlements == 0 && $trial_info) {
            if (time() < str2time($trial_info->{sub_end})) {
                $total = $trial_info->{endpoint_count};
            }
        }
    }

    return $total;
}

=head2 get_used_capacity

Get the current used endpoint capacity

=cut

sub get_used_capacity {
    return pf::node::node_count_active();
}

=head2 is_current_usage_under_limit

Compares the entitlement endpoint limit with daily moving usage avg

=cut

sub is_current_usage_under_limit {
    my ($count_status, $count) = pf::a3_entitlement::get_current_moving_avg_count();
    if (is_success($count_status)) {
        #return true if we only have less than 7 days of moving avg
        return $STATUS::OK, $TRUE if $count < 7;
    }
    else {
        return $STATUS::NOT_FOUND;
    }
    my ($status, $current_moving_avg) = pf::a3_entitlement::get_current_moving_avg();
    if (is_success($status)) {
        return $STATUS::OK, $current_moving_avg <= get_licensed_capacity();
    }
    else {
        return $STATUS::NOT_FOUND;
    }
}

=head2 is_current_entitlement_expired

Checks whether the entitlement is expired

=cut

sub is_current_entitlement_expired {
    my $active_entitlements = pf::a3_entitlement::find_active();
    my ($trial_status, $trial_info) = get_trial_info();
    if (is_success($trial_status)) {
        return $trial_info->{is_expired} && @$active_entitlements == 0;
    }
    else {
        return @$active_entitlements == 0;
    }
}

=head2 is_trial_eligible

Return whether this A3 system is eligible for a trial

=cut

sub is_trial_eligible {
    my $entitlements = pf::a3_entitlement::find_all();
    my $trial_status = get_trial_info();

    return $trial_status == $STATUS::NOT_FOUND && @$entitlements == 0;
}

=head2 start_trial

Starts a trial if eligible

=cut

sub start_trial {
    if (is_trial_eligible) {
        if (is_success(pf::a3_entitlement::create_trial())) {
            my ($status, $trial) = get_trial_info();
            return $status == $STATUS::OK ? $STATUS::CREATED : $status, $trial;
        }
        else {
            return $STATUS::INTERNAL_SERVER_ERROR;
        }
    }
    else {
        return $STATUS::CONFLICT;
    }
}

=head2 get_trial_info

Get information about the status of the trial

=cut

sub get_trial_info {
    my $trial = pf::a3_entitlement::get_trial();

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


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
