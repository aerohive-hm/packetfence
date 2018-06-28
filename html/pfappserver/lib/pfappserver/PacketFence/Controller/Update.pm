package pfappserver::PacketFence::Controller::Update;

=head1 NAME

pfappserver::PacketFence::Controller::Update - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use Moose;
use pf::error qw(is_success is_error);

use pf::log;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 METHODS

=head2 begin

This controller defaults view is JSON.

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
    $c->stash->{current_view} = 'JSON';
}

=head2 latest

Check for a software update / Initiate software update

Usage: /update/latest

A GET request will retrieve information about the current version
of A3 software if it is newer than the current running version.

A POST request will initiate the update process. If successful, it
will return a token that can be used to query the progress of the
update.

=cut

sub latest :Local :Args(0) {
    my ( $self, $c ) = @_;
    my $logger = get_logger();

    my $method = $c->request->method;

    $logger->debug("Received $method request for /update/latest");

    if ($method eq 'GET') {
        $c->stash->{is_update_in_progress} = $c->model('Update')->is_update_in_progress();

        if ($c->stash->{is_update_in_progress}) {
            # TODO: TOCTOU issue - what if update completes between call
            #       to is_update_in_progress and get_update_status?
            $c->stash->{update_progress} = $c->model('Update')->get_update_status();
        }
        else {
            my ($status, $latest) = $c->model('Update')->fetch_latest_release();

            $logger->debug("status = $status, latest = " . Dumper($latest));

            if ($status == $STATUS::OK) {
                $c->stash->{update_info} = $latest;
            }

            $c->response->status($status);
        }
    }
    elsif ($method eq 'POST') {
        $c->response->status( $c->model('Update')->start_update() );
    }
    else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

=head2 progress

Check on the progress of an update operation.

Usage: /update/progress

A GET request will retrieve status of the current update
operation if one is in progress. Otherwise returns HTTP 404

=cut

sub progress :Local {
    my ( $self, $c ) = @_;
    my $logger = get_logger();

    my $method = $c->request->method;

    $logger->debug("Received $method request for /update/progress");

    if ($method eq 'GET') {
        $c->stash->{update_progress} = $c->model('Update')->get_update_status();
    }
    else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
