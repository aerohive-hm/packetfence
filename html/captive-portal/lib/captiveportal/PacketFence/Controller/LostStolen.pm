package captiveportal::PacketFence::Controller::LostStolen;
use Moose;
use namespace::autoclean;
use pf::violation;
use pf::constants::violation qw($LOST_OR_STOLEN);
use pf::node;
use pf::util qw(strip_username);

BEGIN { extends 'captiveportal::Base::Controller'; }

=head1 NAME

captiveportal::PacketFence::Controller::LostStolen - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(1) {
    my ( $self, $c, $mac ) = @_;
    my $node = node_view($mac);
    my $owner = lc($node->{pid});
    my $stripped_owner = strip_username($owner);
    my $username = lc($c->user_session->{username});
    my $stripped_username = strip_username($username);

    $c->stash(
        mac => $mac,
        template => 'lost_stolen.html',
    );
    if ( $stripped_username eq $stripped_owner ) {
        my $trigger = violation_add($mac, $LOST_OR_STOLEN);

        if ($trigger) {
            $c->stash(
                status => 'success',
            );
        } else {
            $c->stash(
                status => 'error',
            );
        }
    } else {
        $c->stash(
            status => 'notowned',
        );
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
