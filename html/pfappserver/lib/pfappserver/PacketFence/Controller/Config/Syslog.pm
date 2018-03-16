package pfappserver::PacketFence::Controller::Config::Syslog;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Syslog - Catalyst Controller

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
        object => { Chained => '/', PathPart => 'config/syslog', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'SYSLOG_READ' },
        list   => { AdminRole => 'SYSLOG_READ' },
        create => { AdminRole => 'SYSLOG_CREATE' },
        clone  => { AdminRole => 'SYSLOG_CREATE' },
        update => { AdminRole => 'SYSLOG_UPDATE' },
        remove => { AdminRole => 'SYSLOG_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::Syslog", form => "Config::Syslog" },
    },
);

=head1 METHODS

=head2 index

Usage: /config/syslog

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->forward('list');
}

before [qw(clone view _processCreatePost update)] => sub {
    my ($self, $c, @args) = @_;
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    my $item = $c->stash->{$itemKey};
    my $type = $item->{type};
    my $form = $c->action->{form};
    $c->stash->{current_form} = "${form}::${type}";
};

sub create_type : Path('create') : Args(1) {
    my ($self, $c, $type) = @_;
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    $c->stash->{$itemKey}{type} = $type;
    $c->forward('create');
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable;

1;
