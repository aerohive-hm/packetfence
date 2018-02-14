package pfappserver::PacketFence::Controller::Config::Networks;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Networks - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use pfappserver::Form::Config::Network;
use pfappserver::Form::Config::Network::Routed;
use namespace::autoclean;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config' => { -excludes => [ qw(getForm) ] };
}

#Reconfigure the object dispatcher from pfappserver::Base::Controller::Crud
__PACKAGE__->config(
    action => {
#Reconfiguring the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/network', CaptureArgs => 1 }
    },
    action_args => {
#Setting the global model for all actions
        '*' => { model => "Config::Network"}
    }
);

=head1 METHODS

=head2 getForm

Gettng the form for the current view

=cut

sub getForm {
    my ( $self, $c ) = @_;
    my $network = $c->stash->{network};
    my $network_ref = $c->stash->{item};
    my $form;
    if (!defined($network) || $network_ref->{next_hop}) {
        # Create or edit a routed network
        $form = $c->form("Config::Network::Routed", network => $network);
    } else {
        # Edit the default interface network
        $form = $c->form("Config::Network", network => $network);
    }
    return $form;
};


=head2 after create

=cut

after create => sub {
    my ($self, $c) = @_;
    if (!(is_success($c->response->status) && $c->request->method eq 'POST' )) {
        $c->stash->{template} = 'config/networks/view.tt';
    }
};

=head2 after view

=cut

after view => sub {
    my ($self, $c) = @_;
    if (!$c->stash->{action_uri}) {
        my $id = $c->stash->{network};
        if ($id) {
            $c->stash->{action_uri} = $c->uri_for($self->action_for('update'), [$c->stash->{network}]);
        } else {
            $c->stash->{action_uri} = $c->uri_for($self->action_for('create'));
        }
    }
};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
