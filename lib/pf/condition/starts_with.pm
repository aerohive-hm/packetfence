package pf::condition::starts_with;
=head1 NAME

pf::condition::starts_with

=cut

=head1 DESCRIPTION

pf::condition::starts_with

Check if the value defined in the condition starts with a value

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);

=head2 value

The value to match against

=cut

has value => (
    is => 'ro',
    required => 1,
    isa  => 'Str',
);

=head2 match

Check if the value starts with the string passed as an argument

=cut

sub match {
    my ($self,$arg) = @_;
    my $value = quotemeta $self->value;
    return 0 if(!defined($arg));
    return $arg =~ /^$value/;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

