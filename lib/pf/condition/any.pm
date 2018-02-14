package pf::condition::any;
=head1 NAME

pf::condition::any

=cut

=head1 DESCRIPTION

pf::condition::any

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use List::MoreUtils qw(any);

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

Matches any the sub conditions

=cut

sub match {
    my ($self, $arg) = @_;
    return any { $_->match($arg) } $self->all_conditions;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

