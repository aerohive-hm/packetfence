package pfappserver::PacketFence::Controller::Config::Firewall_SSO;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Firewall_SSO - Catalyst Controller

=head1 DESCRIPTION

Controller for firewall sso  management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pf::constants::firewallsso;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/firewall_sso', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'FIREWALL_SSO_READ' },
        list   => { AdminRole => 'FIREWALL_SSO_READ' },
        create => { AdminRole => 'FIREWALL_SSO_CREATE' },
        clone  => { AdminRole => 'FIREWALL_SSO_CREATE' },
        update => { AdminRole => 'FIREWALL_SSO_UPDATE' },
        remove => { AdminRole => 'FIREWALL_SSO_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::Firewall_SSO", form => "Config::Firewall_SSO" },
    },
);

=head1 METHODS

=head2 after create clone

Show the 'view' template when creating or cloning a floating device.

=cut

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

=head2 index

Usage: /config/firewall_sso/

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{types} = $pf::constants::firewallsso::FIREWALL_TYPES;
    $c->forward('list');
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
