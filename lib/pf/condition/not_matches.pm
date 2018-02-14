package pf::condition::not_matches;
=head1 NAME

pf::condition::not_matches

=cut

=head1 DESCRIPTION

pf::condition::not_matches

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use pf::constants;

=head2 value

The value to match against

=cut

has value => (
    is => 'ro',
    required => 1,
    isa  => 'Str',
);

=head2 match

Matches if the argument does not match the value

=cut

sub match {
    my ($self,$arg) = @_;
    my $match = $self->value;
    return $FALSE if(!defined($arg));
    return $arg !~ /\Q$match\E/;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

