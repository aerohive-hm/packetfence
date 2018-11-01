package pf::api::can_fork;

=head1 NAME

pf::api::can_fork local client for pf::api

=cut

=head1 DESCRIPTION

pf::api::can_fork

can_fork client for pf::api which calls the api directly and fork on notify for api calls that are marked for forking
To avoid circular dependencies pf::api needs to be included before consuming this module

=cut

use strict;
use warnings;
use pf::log;
use pf::util::webapi;
use POSIX;
use Moo;

our $logger = get_logger();

=head2 call

calls the pf api

=cut

sub call {
    my ($self,$method,@args) = @_;
    pf::util::webapi::add_mac_to_log_context(\@args);
    return pf::api->$method(@args);
}

=head2 notify

calls the pf api ignoring the return value

=cut

sub notify {
    my ($self, $method, @args) = @_;
    my $pid;
    if (pf::api->shouldFork($method)) {
        $pid = fork;
        unless (defined $pid) {
            $logger->error("Error fork $!");
            return;
        }
        if ($pid) {
            $logger->debug("Fork $method off");
            return;
        }
        Log::Log4perl::MDC->put( 'tid', $$ );
    }
    pf::util::webapi::add_mac_to_log_context(\@args);
    eval {pf::api->$method(@args);};
    if ($@) {
        $logger->error("Error handling $method : $@");
    }
    if (defined $pid && $pid == 0 ) {
        POSIX::_exit(0);
    }
    return;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

