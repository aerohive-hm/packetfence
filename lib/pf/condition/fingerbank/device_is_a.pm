package pf::condition::fingerbank::device_is_a;

=head1 NAME

pf::condition::fingerbank::device_is_a - check if a iswitch is inside a switch group

=cut

=head1 DESCRIPTION

pf::condition::fingerbank::device_is_a

=cut

use strict;
use warnings;
use Moose;
use pf::Moose::Types;
extends 'pf::condition';
use pf::log;
use pf::constants;
use fingerbank::Model::Device;

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
    my ($self, $device) = @_;
    $logger->debug("Checking if device $device is a ".$self->value);
    return fingerbank::Model::Device->is_a($device, $self->value);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

