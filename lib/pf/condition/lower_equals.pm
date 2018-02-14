package pf::condition::lower_equals;

=head1 NAME

pf::condition::lower_equals

=cut

=head1 DESCRIPTION

pf::condition::lower_equals

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use pf::constants;

=head2 value

The value to compare against

=cut

has value => (
    is => 'ro',
    required => 1,
    isa  => 'Str',
);

=head2 match

Matches if the argument is less than

=cut

sub match {
    my ($self,$arg) = @_;
    return $FALSE if(!defined($arg));
    no warnings 'numeric';
    return $arg <= $self->value;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
