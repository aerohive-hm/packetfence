package pfappserver::PacketFence::Controller::Config::AdminRoles;

=head1 NAME

pfappserver::PacketFence::Controller::Config::AdminRoles - Catalyst Controller

=head1 DESCRIPTION

Controller for admin roles management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pfappserver::Form::Config::Switch;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/adminroles', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'ADMIN_ROLES_READ' },
        list   => { AdminRole => 'ADMIN_ROLES_READ' },
        create => { AdminRole => 'ADMIN_ROLES_CREATE' },
        clone  => { AdminRole => 'ADMIN_ROLES_CREATE' },
        update => { AdminRole => 'ADMIN_ROLES_UPDATE' },
        remove => { AdminRole => 'ADMIN_ROLES_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::AdminRoles", form => "Config::AdminRoles" },
    },
);

=head1 METHODS

=head2 after _setup_object

Sort the actions of the admin role.

This subroutine is defined in pfappserver::Base::Controller::Crud.

=cut

after _setup_object => sub {
    my ($self, $c) = @_;

    # Sort actions
    if (is_success($c->response->status)) {
        my @actions = sort @{$c->stash->{'item'}->{'actions'}};
        $c->stash->{'item'}->{'actions'} = \@actions;
    }
};

=head2 index

Usage: /config/adminroles/

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->forward('list');
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
