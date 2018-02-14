package pfappserver::PacketFence::Controller::Config::PKI_Provider;

=head1 NAME

pfappserver::PacketFence::Controller::Config::PKI_Provider - Catalyst Controller

=head1 DESCRIPTION

Controller for admin roles management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pf::factory::pki_provider;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/pki_provider', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'PKI_PROVIDER_READ' },
        list   => { AdminRole => 'PKI_PROVIDER_READ' },
        create => { AdminRole => 'PKI_PROVIDER_CREATE' },
        clone  => { AdminRole => 'PKI_PROVIDER_CREATE' },
        update => { AdminRole => 'PKI_PROVIDER_UPDATE' },
        remove => { AdminRole => 'PKI_PROVIDER_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::PKI_Provider", form => "Config::PKI_Provider" },
    },
);

=head1 METHODS

=head2 index

Usage: /config/pki_provider

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my %pki_providers = ();
    foreach my $module ( keys %pf::factory::pki_provider::MODULES ) {
        my $type = $pf::factory::pki_provider::MODULES{$module}{'type'};
        $pki_providers{$type}{'type'} = $type;
        $pki_providers{$type}{'description'} = $pf::factory::pki_provider::MODULES{$module}{'description'};
    }
    $c->stash->{types} = \%pki_providers;

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

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
