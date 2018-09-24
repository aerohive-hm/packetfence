package pf::a3_util;

=head1 NAME

pf::a3_util Support util functions for A3

=head1 DESCRIPTION

Support util functions for A3

=cut

use strict;
use warnings;

use POSIX qw(strftime);

use pf::log;
use pf::error qw(is_success is_error);
use pf::constants qw($TRUE $FALSE );
use JSON;
use WWW::Curl::Easy;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA    = qw(Exporter);
    @EXPORT = qw(a3_cluster_status);
}

=head2 a3_is_cluster_enabled

returns the status of cluster enabled and management node info

=cut

sub a3_cluster_status {

    my $logger = get_logger();
    my $url = "http://127.0.0.1:10000/api/v1/configuration/cluster/status";


    my ($retcode, $response_body, $response_code) = pf::util::call_url('GET', $url, undef);
    if ($retcode == 0 && is_success($response_code)) {
        my $json = JSON->new->allow_nonref;
        my $cluster_status = $json->decode($response_body);
        return $cluster_status->{'is_cluster'}, $cluster_status->{'is_management'};
    } else {
        $logger->error("Falied to call GET on $url ret: $retcode");
        return $FALSE, $FALSE;
    }
}

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;