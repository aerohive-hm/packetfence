package pfappserver::PacketFence::Controller::EulaAcceptance;

=head1 NAME

pfappserver::PacketFence::Controller::EulaAcceptance - Catalyst Controller

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

=head2 eula

End User License Agreement

Usage: /eula

=cut

sub eula :Path('/eula') :Args(0) {
    my ( $self, $c ) = @_;
    my $logger = get_logger();

    $logger->info($c->request->method . ' /eula called');

    if ($c->request->method eq 'POST') {
        if ( ! $c->model('EulaAcceptance')->is_eula_accepted() ) {
            my $result = $c->model('EulaAcceptance')->record_eula_acceptance();

            $c->stash->{eula_accepted} = $result;
            $c->response->{status} = $result ? $STATUS::OK : $STATUS::INTERNAL_SERVER_ERROR;
        }
    }
    elsif ($c->request->method eq 'GET') {
        $c->stash->{is_eula_accepted} = $c->model('EulaAcceptance')->is_eula_accepted();
    }
    my $entitlements = $c->model('Entitlement')->list_entitlement_keys();
    $c->stash->{is_eula_needed} = @$entitlements > 0 && ! $c->model('EulaAcceptance')->is_eula_accepted();
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
