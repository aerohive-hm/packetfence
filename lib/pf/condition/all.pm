package pf::condition::all;
=head1 NAME

pf::condition::all

=cut

=head1 DESCRIPTION

pf::condition::all

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use List::MoreUtils qw(all);

=head2 conditions

The sub conditions to match

=cut

has conditions => (
    traits  => ['Array'],
    isa     => 'ArrayRef[pf::condition]',
    default => sub {[]},
    handles => {
        all_conditions        => 'elements',
        add_condition         => 'push',
        count_conditions      => 'count',
        has_conditions        => 'count',
        no_conditions         => 'is_empty',
    },
);

=head2 match

Matches all the sub conditions

=cut

sub match {
    my ($self, $arg) = @_;
    return all { $_->match($arg) } $self->all_conditions;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

