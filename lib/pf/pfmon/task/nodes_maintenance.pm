package pf::pfmon::task::nodes_maintenance;

=head1 NAME

pf::pfmon::task::nodes_maintenance - class for pfmon task nodes maintenance

=cut

=head1 DESCRIPTION

pf::pfmon::task::nodes_maintenance

=cut

use strict;
use warnings;
use Moose;
use pf::node;
extends qw(pf::pfmon::task);


=head2 run

run the nodes maintenance task

=cut

sub run {
    nodes_maintenance();
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
