package pfappserver::PacketFence::Controller::SavedSearch::RadiusLog;

=head1 NAME

pfappserver::PacketFence::Controller::SavedSearch::RadiusLog - Saved Search for RadiusLog

=cut

=head1 DESCRIPTION

RadiusLog

=cut

use strict;
use warnings;
use Moose;
use HTTP::Status qw(:constants is_error is_success);

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object dispatcher from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'savedsearch/node', CaptureArgs => 1 },
        view   => { AdminRole => 'RADIUS_LOG_READ' },
        list   => { AdminRole => 'RADIUS_LOG_READ' },
        create => { AdminRole => 'RADIUS_LOG_READ' },
        update => { AdminRole => 'RADIUS_LOG_READ' },
        remove => { AdminRole => 'RADIUS_LOG_READ' },
    },
    action_args => {
        '*' => { model => 'SavedSearch::RadiusLog', form => 'SavedSearch'}
    }
);

=head1 METHODS

=head2 before create

=cut

before 'create' => sub {
    my ( $self, $c ) = @_;
    $c->request->parameters->{pid} = $c->user->id;
};


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

