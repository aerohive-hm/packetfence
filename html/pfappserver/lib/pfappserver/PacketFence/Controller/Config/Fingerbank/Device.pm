package pfappserver::PacketFence::Controller::Config::Fingerbank::Device;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Fingerbank::Device

=head1 DESCRIPTION

Controller for managing the fingerbank Device data

=cut

use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;
use HTTP::Status qw(:constants :is);

BEGIN {
    extends 'pfappserver::Base::Controller';
    #Since we are creating our own list action to import it into our namespace
    with 'pfappserver::Base::Controller::Crud::Fingerbank' => { -excludes => 'index' };
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object and scope actions from
        __PACKAGE__->action_defaults,
        scope  => { Chained => '/', PathPart => 'config/fingerbank/device', CaptureArgs => 1 },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => __PACKAGE__->get_model_name , form => __PACKAGE__->get_form_name },
    },
);


sub index: Path :Args(0) {
    my ($self, $c) = @_;
    $c->visit('Config::Fingerbank::Device::Upstream' => 'index');
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
