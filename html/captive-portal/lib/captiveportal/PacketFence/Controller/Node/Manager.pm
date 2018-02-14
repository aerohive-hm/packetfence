package captiveportal::PacketFence::Controller::Node::Manager;

use Moose;
use namespace::autoclean;
use pf::constants;
use pf::config;
use pf::node;
use pf::enforcement qw(reevaluate_access);

BEGIN {extends 'captiveportal::Base::Controller'; }

=head1 NAME

captiveportal::PacketFence::Controller::Node::Manager - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 unreg

=cut

sub unreg :Local :Args(1) {
    my ($self, $c, $mac) = @_;
    my $node = node_view($mac);
    my $username = lc($c->user_session->{username});
    my $owner = lc($node->{pid});
    if ($username && $node) {
        $c->log->info("'$username' attempting to unregister $mac owned by '$owner'");
        if (($username ne $default_pid && $username ne $admin_pid ) && $username eq $owner) {
            node_deregister($mac, %$node);
            reevaluate_access($mac, "node_modify");
            $c->response->redirect("/status");
            $c->detach;
        } else {
            $self->showError($c,"Not allowed to deregister $mac");
        }

    } else {
        $self->showError($c,"Not logged in or node ID $mac is not known");
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
