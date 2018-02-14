package pf::condition::not_equals;
=head1 NAME

pf::condition::not_equals

=cut

=head1 DESCRIPTION

pf::condition::not_equals

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

Match if the argument if not equal to the value

=cut

sub match {
    my ($self,$arg) = @_;
    return $FALSE if(!defined($arg));
    return $arg ne $self->value;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

