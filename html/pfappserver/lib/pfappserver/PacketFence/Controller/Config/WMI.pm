package pfappserver::PacketFence::Controller::Config::WMI;

=head1 NAME

pfappserver::PacketFence::Controller::Config::WMI - Catalyst Controller

=head1 DESCRIPTION

Controller for WMI Rules.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;


BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/wmi', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'WMI_READ' },
        list   => { AdminRole => 'WMI_READ' },
        create => { AdminRole => 'WMI_CREATE' },
        clone  => { AdminRole => 'WMI_CREATE' },
        update => { AdminRole => 'WMI_UPDATE' },
        remove => { AdminRole => 'WMI_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::WMI", form => "Config::WMI" },
    },
);

=head1 METHODS

=head2 after create clone

Show the 'view' template when creating or cloning realm.

=cut

after [qw(create clone)] => sub {
    my ($self, $c) = @_;
    if (!(is_success($c->response->status) && $c->request->method eq 'POST' )) {
        $c->stash->{template} = 'config/wmi/view.tt';
    }
};

=head2 after view

=cut

after view => sub {
    my ($self, $c) = @_;
    if (!$c->stash->{action_uri}) {
        my $id = $c->stash->{id};
        if ($id) {
            $c->stash->{action_uri} = $c->uri_for($self->action_for('update'), [$c->stash->{id}]);
        } else {
            $c->stash->{action_uri} = $c->uri_for($self->action_for('create'));
        }
    }
};

=head2 index

Usage: /config/wmi/

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
