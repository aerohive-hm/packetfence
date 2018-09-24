package pf::a3_eula_acceptance;

=head1 NAME

pf::a3_eula_acceptance Support functions for A3 EULA handling

=head1 DESCRIPTION

Support functions for A3 EULA handling

=cut

use strict;
use warnings;

use pf::log;
use pf::error qw(is_success is_error);
use pf::config qw(%Config);
use pf::constants qw($TRUE $FALSE $A3_SYSTEM_ID);
use pf::dal::a3_eula_acceptance;

use JSON;
use WWW::Curl::Easy;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA    = qw(Exporter);
    @EXPORT = qw(a3_is_eula_accepted);
}

=head2 record_local

Saves a local record of the time at which the Aerohive EULA was accepted.

=cut

sub record_local {
    my ( $timestamp ) = @_;

    my $logger = get_logger();

    my $status = pf::dal::a3_eula_acceptance->create({
        timestamp => $timestamp->strftime('%Y-%m-%d %H:%M:%S'),
        is_synced => $FALSE
    });

    return is_success($status)
}

=head2 record_acs

Notifies ACS about the EULA acceptance event

=cut

sub record_acs {
    my ( $timestamp ) = @_;

    my $logger = get_logger();

    my $acs_eula_url = "$Config{A3}->{license_server}$Config{A3}->{eula_path}/$A3_SYSTEM_ID";

    my $curl = WWW::Curl::Easy->new;

    $curl->setopt(CURLOPT_POST, 1);
    $curl->setopt(CURLOPT_URL, $acs_eula_url);

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
        timestamp => $timestamp->strftime('%Y-%m-%dT%H:%M:%S')
    );

    $curl->setopt(CURLOPT_POSTFIELDS, $json->encode(\%request));

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    my $retcode = $curl->perform;

    $logger->info("retcode = $retcode");

    if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);

        $logger->info("response $response_code: $response_body");
        return is_success($response_code);
    }

    return $FALSE;
}

=head2 record_sync

Updates the local record to indicate that the EULA acceptance event was
successfully recorded by ACS

=cut

sub record_sync {
    my ( $timestamp ) = @_;

    my ($status) = pf::dal::a3_eula_acceptance->update_items(
        -set   => {
            is_synced => $TRUE
        },
        -where => {
            timestamp => $timestamp->strftime('%Y-%m-%d %H:%M:%S')
        }
    );
}

=head2 is_eula_accepted

Returns whether the EULA has been accepted already

=cut

sub a3_is_eula_accepted {
    return pf::dal::a3_eula_acceptance->count() > 0;
}

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
