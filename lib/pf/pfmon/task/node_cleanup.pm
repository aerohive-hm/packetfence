package pf::pfmon::task::node_cleanup;

=head1 NAME

pf::pfmon::task::node_cleanup - class for pfmon task node cleanup

=cut

=head1 DESCRIPTION

pf::pfmon::task::node_cleanup

=cut

use strict;
use warnings;
use pf::node;
use Moose;
extends qw(pf::pfmon::task);

has 'delete_window' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );

has 'unreg_window' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );

=head2 run

run the node cleanup task

=cut

sub run {
    my ($self) = @_;
    node_cleanup($self->delete_window, $self->unreg_window);
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
