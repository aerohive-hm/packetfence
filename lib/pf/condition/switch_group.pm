package pf::condition::switch_group;

=head1 NAME

pf::condition::switch_group - check if a iswitch is inside a switch group

=cut

=head1 DESCRIPTION

pf::condition::switch_group

=cut

use strict;
use warnings;
use Moose;
use pf::Moose::Types;
extends 'pf::condition';
use pf::log;
use pf::constants;

our $logger = get_logger();

=head1 ATTRIBUTES

=head2 value

The Switch to match against

=cut

has 'value' => (
    is       => 'ro',
    required => 1,
    isa => 'Str',
);

=head1 METHODS

=head2 match

match the last ip to see if it is in defined network

=cut

sub match {
    my ($self, $last_switch) = @_;
    return $FALSE unless defined $last_switch;
    my $switch = pf::SwitchFactory->instantiate($last_switch);
    return $FALSE unless defined $switch;
    if (defined($switch->{_group}) & $switch->{_group} eq $self->value) {
        return $TRUE;
    } else {
        return $FALSE;
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
