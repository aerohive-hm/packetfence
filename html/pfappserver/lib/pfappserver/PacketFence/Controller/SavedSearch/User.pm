package pfappserver::PacketFence::Controller::SavedSearch::User;

=head1 NAME

pfappserver::PacketFence::Controller::SavedSearch::User add documentation

=cut

=head1 DESCRIPTION

User

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
        object => { Chained => '/', PathPart => 'savedsearch/user', CaptureArgs => 1 },
        view   => { AdminRoleAny => [qw(USERS_READ USERS_READ_SPONSORED)] },
        list   => { AdminRoleAny => [qw(USERS_READ USERS_READ_SPONSORED)] },
        create => { AdminRoleAny => [qw(USERS_READ USERS_READ_SPONSORED)] },
        update => { AdminRoleAny => [qw(USERS_READ USERS_READ_SPONSORED)] },
        remove => { AdminRoleAny => [qw(USERS_READ USERS_READ_SPONSORED)] },
    },
    action_args => {
        '*' => { model => 'SavedSearch::User', form => 'SavedSearch'}
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

