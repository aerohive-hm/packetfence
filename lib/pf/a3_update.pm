package pf::a3_update;

=head1 NAME

pf::a3_update Support functions for A3 software update

=head1 DESCRIPTION

Support functions for A3 software update

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

=head2 get_latest_release_from_acs

Get information about the latest release from ACS

=cut

sub get_latest_release_from_acs {
    my $logger = get_logger();

    my $acs_release_info_url = "$Config{A3}->{license_server}$Config{A3}->{release_info_path}";

    $logger->info("Retrieving release information from ACS at $acs_release_info_url");

    my $curl = WWW::Curl::Easy->new;

    $curl->setopt(CURLOPT_URL, $acs_release_info_url);

    $curl->setopt(CURLOPT_HTTPHEADER, [
        'Accept: application/json'
    ]);

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    my $retcode = $curl->perform;

    if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);

        my $json = JSON->new->allow_nonref;

        $logger->info("Response from ACS: ($response_code) $response_body");

        return is_success($response_code), $json->decode($response_body);
    }

    $logger->warn("curl returned $retcode");

    return $FALSE;
}

sub compare_versions {
    my ($v1, $v2) = @_;

    my $logger = get_logger();

    $logger->debug("Comparing $v1 and $v2");

    my @v1_parts = split /\./, $v1;
    my @v2_parts = split /\./, $v2;

    if (($v1_parts[0] - $v2_parts[0]) != 0) {
        return $v1_parts[0] - $v2_parts[0];
    }

    if (($v1_parts[1] - $v2_parts[1]) != 0) {
        return $v1_parts[1] - $v2_parts[1];
    }

    if (($v1_parts[2] - $v2_parts[2]) != 0) {
        return $v1_parts[2] - $v2_parts[2];
    }

    return 0;
}

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
