package pfappserver::PacketFence::Controller::A3;

use HTML::Entities;
use HTTP::Status qw(:constants is_error is_success);
use Moose;

use pf::config qw(%Config);
use List::MoreUtils qw(all);
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

sub begin :Private {
	my ( $self, $c ) = @_;
	$c->stash->{current_view} = 'A3';
}

sub index :Path :Args(0) {
	my ( $self, $c ) = @_;
	$c->response->redirect($c->uri_for($self->action_for('init')));
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

