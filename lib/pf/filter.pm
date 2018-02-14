package pf::filter;

=head1 NAME

pf::filter

=cut

=head1 DESCRIPTION

pf::filter

=cut

use strict;
use warnings;
use Moose;

=head1 ATTRIBUTES

=head2 conditions

The conditions of the filter

=cut

has condition => (
    is => 'ro',
    isa => 'pf::condition',
);

=head2 answer

The answer of the filter

=cut

has answer => (
   is => 'ro',
   required => 1,
);

=head1 METHODS

=head2 match

Test to see if the condition of the filter matches

=cut

sub match {
    my ($self,$arg) = @_;
    return $self->condition->match($arg);
}

=head2 get_answer

Returns the answer

=cut

sub get_answer {
    my ($self) = @_;
    return $self->answer;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

