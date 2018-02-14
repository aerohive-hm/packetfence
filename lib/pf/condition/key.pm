package pf::condition::key;
=head1 NAME

pf::condition::key

=cut

=head1 DESCRIPTION

pf::condition::key

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use pf::constants;
use Scalar::Util qw(reftype);

=head2 key

The key to match in the hash

=cut

has key => (
    is => 'ro',
    required => 1,
    isa  => 'Str',
);

=head2 condition

The sub condition to match

=cut

has condition => (
    is => 'ro',
    required => 1,
    isa => 'pf::condition',
);

=head2 match

Match a sub condition using the value in a hash

=cut

sub match {
    my ($self,$arg) = @_;
    return $FALSE unless defined $arg && reftype ($arg) eq 'HASH';
    my $key = $self->key;
    return $FALSE unless exists $arg->{$key};
    return $self->condition->match($arg->{$key});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

