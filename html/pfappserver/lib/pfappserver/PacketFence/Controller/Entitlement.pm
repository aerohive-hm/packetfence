package pfappserver::PacketFence::Controller::Entitlement;

=head1 NAME

pfappserver::PacketFence::Controller::Entitlement - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use Moose;

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
        $c->stash->{entitlement_key} = $c->model('Entitlement')->apply_entitlement_key($key);
    }
    elsif ($c->request->method eq 'GET') {
        $c->stash->{entitlement_key} = $c->model('Entitlement')->get_entitlement_key($key);
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


=head2 licenseKeys

=cut

sub licenseKeys :Path('licenseKeys') :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{template} = "entitlement/licenseKeys.tt";

    $c->stash->{entitlement_keys} = $c->model('Entitlement')->list_entitlement_keys();
    $c->stash->{max_capacity} = $c->model('Entitlement')->get_licensed_capacity();
    $c->stash->{used_capacity} = $c->model('Entitlement')->get_used_capacity();
    $c->stash->{system_id} = `/usr/bin/cat /etc/A3.systemid`;

    $c->forward('View::HTML');
}

sub licenseKey :Path('licenseKey') :Args(1) {
    my ( $self, $c, $key ) = @_;
    $c->stash->{template} = "admin/licenseKeys.tt";

    if ($c->request->method eq 'PUT') {
        $c->stash->{entitlement_key} = $c->model('Entitlement')->apply_entitlement_key($key);
    }
    elsif ($c->request->method eq 'GET') {
        $c->stash->{entitlement_key} = $c->model('Entitlement')->get_entitlement_key($key);
    }
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;