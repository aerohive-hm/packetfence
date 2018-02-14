package pfappserver::PacketFence::Controller::Config::System;

=head1 NAME

pfappserver::PacketFence::Controller::Config::System - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;

BEGIN { extends 'pfappserver::Base::Controller'; }

=head1 METHODS

=over

=item create

*NOT IMPLEMENTED*

Usage: /config/system/create

=cut

sub create :Path('create') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->status(HTTP_NOT_IMPLEMENTED);
}

=item delete

*NOT IMPLEMENTED*

Usage: /config/system/delete

=cut

sub delete :Path('create') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->status(HTTP_NOT_IMPLEMENTED);
}

=item read

*NOT IMPLEMENTED*

Usage: /config/system/read

=cut

sub read :Path('read') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->status(HTTP_NOT_IMPLEMENTED);
}

=item update

Update the network interface configurations on system

Usage: /config/system/update

=cut

sub update :Path('update') :Args(0) {
    my ( $self, $c ) = @_;

    my $interfaces          = $c->model('Interface')->get('all');
    my $gateway             = $c->request->params->{'gateway'};
    my ($status, $return)   = $c->model('Config::System')->write_network_persistent($interfaces, $gateway);

    if ( is_success($status) ) {
        $c->stash->{status_msg} = $return;
    } else {
        $c->response->status($status);
        $c->error($return);
    }
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
