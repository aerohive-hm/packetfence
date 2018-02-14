package pf::condition::regex;

=head1 NAME

pf::condition::regex

=cut

=head1 DESCRIPTION

pf::condition::regex

=cut

use strict;
use warnings;
use Moose;
use pf::Moose::Types;
extends qw(pf::condition);
use pf::constants;

=head2 value

The value to match against

=cut

has value => (
    is => 'ro',
    required => 1,
);

=head2 match

Match if argument matches the regex defined

=cut

sub match {
    my ($self,$arg) = @_;
    my $match = $self->value;
    return 0 if(!defined($arg));
    return $arg =~ /$match/;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

