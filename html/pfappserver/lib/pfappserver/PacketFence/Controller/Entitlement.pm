package pfappserver::PacketFence::Controller::Entitlement;

=head1 NAME

pfappserver::PacketFence::Controller::Entitlement - Catalyst Controller

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

=head2 key

Entitlement Key

Usage: /entitlement/key/<entitlement-key>

=cut

sub key :Path('key') :Args(1) {
    my ( $self, $c, $key ) = @_;

    if ($c->request->method eq 'PUT') {
        my $ek = $c->model('Entitlement')->apply_entitlement_key($key);

        if ($ek->{err_status}) {
            if ($ek->{err_status} == $STATUS::CONFLICT) {
                $c->stash->{status_msg} = $c->loc("Entitlement key is already in use.");
            }
            elsif ($ek->{err_status} >= 500) {
                $c->stash->{status_msg} = $c->loc("Unable to validate entitlement key at this time. Try again later.");
            }
            else {
                $c->stash->{status_msg} = $c->loc("Entitlement key does not exist or is not valid.");
            }
        }
        else {
            if ($ek->{err_status} == undef){
                $c->stash->{entitlement} = make_ek_hash($ek);
            } else {
                $c->stash->{status_msg} = $c->loc("Unable to validate entitlement key at this time. Try again later...");
            }
        }
    }
    elsif ($c->request->method eq 'GET') {
        my $ek = $c->model('Entitlement')->get_entitlement_key($key);

        if ($ek) {
            $c->stash->{entitlement} = make_ek_hash($ek);
        }
        else {
            $c->response->status($STATUS::NOT_FOUND);
        }
    }
}

=head2 keys

List entitlement keys.

Usage: /entitlement/keys

=cut

sub keys :Path('keys') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{entitlement_keys} = $c->model('Entitlement')->list_entitlement_keys();
}

=head2 usageCheck

checks the current moving avg against allowed capacity

=cut

sub usageCheck :Path('usageCheck') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{is_under_capacity} = $c->model('Entitlement')->is_current_usage_under_limit();
    $c->stash->{current_mov_avg} = $c->model('Entitlement')->get_moving_avg();
}

=head2 licenseKeys

=cut

sub licenseKeys :Path('licenseKeys') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = "entitlement/licenseKeys.tt";

    $c->stash->{entitlement_keys} = $c->model('Entitlement')->list_entitlement_keys();
    $c->stash->{max_capacity} = $c->model('Entitlement')->get_licensed_capacity();
    $c->stash->{used_capacity} = $c->model('Entitlement')->get_used_capacity();
    $c->stash->{system_id} = `/usr/bin/cat /etc/A3.systemid`;

    my $entitlements = $c->model('Entitlement')->list_entitlement_keys();
    $c->stash->{is_eula_needed} = @$entitlements > 0 && ! $c->model('EulaAcceptance')->is_eula_accepted();
    $c->forward('View::HTML');

}

=head2 trial

Initiate trial / get trial status
Usage: /entitlement/trial

=cut

sub trial :Path('trial') :Args(0) {
    my ( $self, $c ) = @_;
    my ($status, $trial);

    if ($c->request->method eq 'POST') {
        # Start a trial if available
        ($status, $trial) = $c->model('Entitlement')->start_trial();
    }
    else {
        # Get current trial status
        ($status, $trial) = $c->model('Entitlement')->get_trial_info();
    }

    $c->response->status($status);

    if (is_success($status)) {
        $c->stash->{trial} = [
            {
                endpoint_count => $trial->{endpoint_count},
                is_expired     => $trial->{is_expired},
                expires_in     => $trial->{expires_in}
            }
        ];
    }

}

sub make_ek_hash {
    my ($ek) = @_;

    return {
        entitlement_key => $ek->{entitlement_key},
        type            => $ek->{type},
        status          => $ek->{status},
        endpoint_count  => $ek->{endpoint_count},
        sub_start       => $ek->{sub_start},
        sub_end         => $ek->{sub_end},
        support_start   => $ek->{support_start},
        support_end     => $ek->{support_end}
    };

}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
