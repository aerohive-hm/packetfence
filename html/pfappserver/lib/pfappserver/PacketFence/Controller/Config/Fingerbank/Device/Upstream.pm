package pfappserver::PacketFence::Controller::Config::Fingerbank::Device::Upstream;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Fingerbank::Device::Upstream

=head1 DESCRIPTION

Controller for managing the fingerbank Device data

=cut

use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;
use HTTP::Status qw(:constants :is);

BEGIN {
    extends 'pfappserver::Base::Controller';
    #Since we are creating our own list action to import it into our namespace
    with 'pfappserver::Base::Controller::Crud::Fingerbank' => { -excludes => 'list' };
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object and scope actions from
        __PACKAGE__->action_defaults,
        scope  => { Chained => '/', PathPart => 'config/fingerbank/device/Upstream', CaptureArgs => 0 },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => 'Config::Fingerbank::Device', form => 'Config::Fingerbank::Device' },
    },
);


=head2 list

List the top level devices

=cut

sub list : Local :Args(0) {
    my ($self, $c) = @_;
    #setting the id of the parent to undef
    $c->stash(
        item => { id => undef },
        scope => 'Upstream',
    );
    $c->forward('children');
}

=head2 children

Show child devices

=cut

sub children : Chained('object'): Local :Args(0) {
    my ($self, $c) = @_;
    my $model = $self->getModel($c);
    my ($status, $devices) = $model->getSubDevices($c->stash->{item}->{id});
    if(is_success($status)) {
        $c->stash->{items} = $devices;
    } else {
        $c->stash->{items} = [];
    }
}

=head2 add_child

create a child device

=cut

sub add_child : Chained('object') :PathPart('add_child') :Args(0) {
    my ( $self, $c ) = @_;
    if ($c->request->method eq 'POST') {
        $self->_processCreatePost($c);
    }
    else {
        my $model = $self->getModel($c);
        my $itemKey = $model->itemKey;
        my $idKey = $model->idKey;
        my $item = delete $c->stash->{$itemKey};
        my $parent_id = delete $item->{$idKey};
        my $form = $self->getForm($c);
        $form->process(init_object => {parent_id => $parent_id} );
        $c->stash(form => $form);
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
