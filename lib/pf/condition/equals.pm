package pf::condition::equals;
=head1 NAME

pf::condition::equals

=cut

=head1 DESCRIPTION

pf::condition::equals

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use pf::constants;

=head2 value

The value match against

=cut

has value => (
    is => 'ro',
    required => 1,
    isa  => 'Str',
);

=head2 match

Check is the $arg equals the value

=cut

sub match {
    my ($self,$arg) = @_;
    return $FALSE if(!defined($arg));
    return $arg eq $self->value;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

