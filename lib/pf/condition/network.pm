package pf::condition::network;

=head1 NAME

pf::condition::network - check if a value is inside a network

=cut

=head1 DESCRIPTION

pf::condition::network

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

The IP network to match against

=cut

has 'value' => (
    is       => 'ro',
    required => 1,
    isa => 'NetAddrIpStr',
    coerce => 1,
);

=head1 METHODS

=head2 match

match the last ip to see if it is in defined network

=cut

sub match {
    my ($self, $ip) = @_;
    return $FALSE unless defined $ip;

    my $ip_addr = eval { NetAddr::IP->new($ip) };
    unless (defined $ip_addr) {
        $logger->info("'$ip' is not a valid ip address or range");
        return $FALSE;
    }
    return $self->value->contains($ip_addr);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
