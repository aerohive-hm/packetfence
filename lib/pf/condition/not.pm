package pf::condition::not;

=head1 NAME

pf::condition::not

=cut

=head1 DESCRIPTION

pf::condition::not

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);

has condition => (
    is => 'ro',
    required => 1,
    isa => 'pf::condition',
);

sub match {
    my ($self,$arg) = @_;
    return !$self->condition->match($arg);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
