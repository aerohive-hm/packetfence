package pfappserver::PacketFence::Controller::Config::TrafficShaping;

=head1 NAME

pfappserver::PacketFence::Controller::Config::TrafficShaping - Catalyst Controller

=head1 DESCRIPTION

Controller for traffic shaping management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pfappserver::Form::Config::Switch;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/trafficshaping', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'TRAFFIC_SHAPING_READ' },
        list   => { AdminRole => 'TRAFFIC_SHAPING_READ' },
        create => { AdminRole => 'TRAFFIC_SHAPING_CREATE' },
        create_type => { AdminRole => 'TRAFFIC_SHAPING_CREATE' },
        create_or_update => { AdminRole => 'TRAFFIC_SHAPING_CREATE' },
        update => { AdminRole => 'TRAFFIC_SHAPING_UPDATE' },
        remove => { AdminRole => 'TRAFFIC_SHAPING_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::TrafficShaping", form => "Config::TrafficShaping" },
    },
);

=head1 METHODS

=head2 index

Usage: /config/trafficshaping

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->forward('list');
}


=head2 before list

/config/trafficshaping/list

=cut

before list => sub {
    my ($self, $c) = @_;
    my $cs = $c->model('Config::TrafficShaping');
    my ($status, $ids) = $cs->readAllIds;
    my %have = map { $_ => undef} @$ids;
    ($status, my $roles) = $c->model('Config::Roles')->listFromDB;
    my @roles_to_show = grep { !exists $have{$_->{name}} } @$roles;
    $c->stash(
       roles => \@roles_to_show
    );

    return ;
};


=head2 create_type

/config/trafficshaping/create/$role

=cut

sub create_type : Path('create') : Args(1) {
    my ($self, $c, $role) = @_;
    my ($status, $msg) = $c->model('Config::Roles')->hasId($role);
    if (is_error($status)) {
        $c->response->status($status);
        $c->stash->{status_msg} = $msg;
        $c->stash->{current_view} = 'JSON';
        $c->detach();
    }
    else {
        my $model = $self->getModel($c);
        my $itemKey = $model->itemKey;
        $c->stash->{$itemKey}{id} = $role;
        $c->forward('create');
    }
}

=head2 create_or_update

/config/trafficshaping/create_or_update/$role

=cut

sub create_or_update : Local : Args(1) {
    my ($self, $c, $role) = @_;
    my ($status, $msg) = $c->model('Config::Roles')->hasId($role);
    if (is_error($status)) {
        $c->response->status($status);
        $c->stash->{status_msg} = $msg;
        $c->stash->{current_view} = 'JSON';
        $c->detach();
        return;
    }
    my $model = $self->getModel($c);
    ($status, $msg) =  $model->hasId($role);
    if (is_success($status)) {
        $c->go('view', [$role], []);
    } else {
        $c->forward('create_type', [$role]);
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable;

1;
