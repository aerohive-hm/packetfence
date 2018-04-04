package pf::a3_entitlement;

=head1 NAME

pf::a3_entitlement Support functions for A3 entitlement

=head1 DESCRIPTION

Support functions for A3 entitlement

=cut

use strict;
use warnings;
use Readonly;

Readonly::Scalar our $KEY_STATUS_UNUSED   => 1;
Readonly::Scalar our $KEY_STATUS_ACTIVE   => 2;
Readonly::Scalar our $KEY_STATUS_INACTIVE => 3;

use pf::log;
use pf::error qw(is_success is_error);
use pf::config qw(%Config);
use pf::constants qw($TRUE $FALSE $A3_SYSTEM_ID);
use pf::dal::a3_entitlement;

use JSON;
use WWW::Curl::Easy;

=head2 find_one

Finds a single entitlement key applied to the current system

=cut

sub find_one {
    my ( $key ) = @_;

    my ( $status, $dal ) = pf::dal::a3_entitlement->find({entitlement_key => $key});

    return is_success($status) ? $dal : $FALSE;
}

=head2 find_all

Returns all of the entitlement keys applied to the current system

=cut

sub find_all {
    my $logger = get_logger();

    my ($status, $iter) = pf::dal::a3_entitlement->search();

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