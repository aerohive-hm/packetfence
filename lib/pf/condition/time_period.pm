package pf::condition::time_period;
=head1 NAME

pf::condition::time_period -

=cut

=head1 DESCRIPTION

pf::condition::time_period

=cut

use strict;
use warnings;
use Time::Period;
use Moose;

extends 'pf::condition';

has value => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

sub match {
    my ($self, $args) = @_;
    return inPeriod(time(),$self->value) > 0;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

