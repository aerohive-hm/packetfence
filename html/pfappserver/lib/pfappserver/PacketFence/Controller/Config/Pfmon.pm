package pfappserver::PacketFence::Controller::Config::Pfmon;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Pfmon - Catalyst Controller

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
        object => { Chained => '/', PathPart => 'config/pfmon', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'PFMON_READ' },
        list   => { AdminRole => 'PFMON_READ' },
        update => { AdminRole => 'PFMON_UPDATE' },
        # The following are noops it will fail
        create => { AdminRole => 'PFMON_READ' },
        clone  => { AdminRole => 'PFMON_READ' },
        remove => { AdminRole => 'PFMON_READ' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::Pfmon", form => "Config::Pfmon" },
    },
);

=head1 METHODS

=head2 index

Usage: /config/pfmon

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->forward('list');
}

before [qw(create clone remove)] => sub {
    my ($self, $c) = @_;
    my $name = $c->action->name;
    $c->log->error("cannot perform the following action on a pfmon task $name");
    $c->detach();
};

before [qw(view update)] => sub {
    my ($self, $c, @args) = @_;
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    my $item = $c->stash->{$itemKey};
    my $type = $item->{type};
    my $form = $c->action->{form};
    $c->stash->{current_form} = "${form}::${type}";
};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
