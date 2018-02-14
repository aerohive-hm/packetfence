package captiveportal::PacketFence::Controller::Enabler;
use Moose;
use namespace::autoclean;
use pf::violation;
use pf::class;

BEGIN { extends 'captiveportal::Base::Controller'; }

=head1 NAME

captiveportal::PacketFence::Controller::Enabler - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    my $portalSession = $c->portalSession;
    my $mac           = $portalSession->clientMac;

    $c->stash->{'user_agent'} = $c->request->user_agent;

    # check for open violations
    my $violation = violation_view_top($mac);

    if ($violation) {

        # There is a violation, redirect the user
        # FIXME: there is not enough validation below
        my $vid   = $violation->{'vid'};
        my $class = class_view($vid);
        $c->stash(
            violation_id => $vid,
            enable_text  => $class->{button_text},
            template     => 'enabler.html',
        );
    } else {
        $self->showError( $c, "error: not found in the database" );
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
