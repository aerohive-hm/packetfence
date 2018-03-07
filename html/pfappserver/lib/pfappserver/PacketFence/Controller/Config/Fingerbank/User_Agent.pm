package pfappserver::PacketFence::Controller::Config::Fingerbank::User_Agent;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Fingerbank::User_Agent

=head1 DESCRIPTION

Controller for managing the fingerbank User_Agent data

=cut

use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Fingerbank' => { -excludes => 'index' };
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object and scope actions from
        __PACKAGE__->action_defaults,
        scope  => { Chained => '/', PathPart => 'config/fingerbank/user_agent', CaptureArgs => 1 },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => __PACKAGE__->get_model_name , form => __PACKAGE__->get_form_name },
    },
);

=head1 index

Setup the scope and forwards

Overwrite L<pfappserver::Base::Controller::Crud::Fingerbank::index> because we don't want "upstream" scope with Combinations

=cut

sub index {
    my ( $self, $c ) = @_;

    $c->stash(
        scope                   => 'Local',
        fingerbank_configured   => fingerbank::Config::is_api_key_configured,
        action                  => 'list',
    );
    $c->forward('list');
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
