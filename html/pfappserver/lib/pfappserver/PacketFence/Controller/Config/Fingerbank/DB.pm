package pfappserver::PacketFence::Controller::Config::Fingerbank::DB;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Fingerbank::DB

=head1 DESCRIPTION

Basic interaction with Fingerbank database.

Customizations can be made using L<pfappserver::Controller::Config::Fingerbank::DB>

=cut

use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;
use pf::constants;
use pf::util;
use pf::config::util;
use pf::error qw(is_success);

BEGIN { extends 'pfappserver::Base::Controller'; }

=head2 update_upstream_db

Update "local" upstream Fingerbank database from Fingerbank project

=cut

sub update_upstream_db :Local :Args(0) :AdminRole('FINGERBANK_UPDATE') {
    my ( $self, $c ) = @_;

    $c->stash->{current_view} = 'JSON';

    pf::cluster::notify_each_server('fingerbank_update_component', action => "update-upstream-db", email_admin => $TRUE, fork_to_queue => $TRUE);

    $c->stash->{status_msg} = $c->loc("Successfully dispatched update request for Fingerbank upstream DB. An email will follow for status");
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
