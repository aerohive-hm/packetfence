package pf::pfmon::task::violation_maintenance;

=head1 NAME

pf::pfmon::task::violation_maintenance - class for pfmon task violation maintenance

=cut

=head1 DESCRIPTION

pf::pfmon::task::violation_maintenance

=cut

use strict;
use warnings;
use Moose;
use pf::violation;
extends qw(pf::pfmon::task);

has 'batch' => ( is => 'rw');
has 'timeout' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );

=head2 run

run the violation maintenance task

=cut

sub run {
    my ($self) = @_;
    violation_maintenance($self->batch, $self->timeout);
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
