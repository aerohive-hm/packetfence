package pf::condition::includes;
=head1 NAME

pf::condition::includes

=cut

=head1 DESCRIPTION

pf::condition::includes

Check if an array includes the value defined in the condition

=cut

use strict;
use warnings;
use Moose;
use pf::constants;
use Scalar::Util qw(reftype);
use List::MoreUtils qw(any);
extends qw(pf::condition);

=head2 value

Value that should be included in the array for the condition to be true

=cut

has value => (
    is => 'ro',
    required => 1,
    isa  => 'Str',
);

=head2 match

Check if the value is part of the array that is passed as an argument

=cut

sub match {
    my ($self, $arg) = @_;
    return $FALSE if !defined $arg;
    my $reftype = reftype($arg) // '';
    return any { $self->value eq $_ } ($reftype eq 'ARRAY' ? @$arg : $arg);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

