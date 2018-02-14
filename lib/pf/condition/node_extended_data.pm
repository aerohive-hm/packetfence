package pf::condition::node_extended_data;

=head1 NAME

pf::condition::node_extended_data -

=cut

=head1 DESCRIPTION

pf::condition::node_extended

=cut

use strict;
use warnings;
use Moose;
use pf::constants qw($TRUE $FALSE);
use pf::extended_node_data qw(extended_node_get_data);
extends qw(pf::condition::key);
use Scalar::Util qw(reftype);

=head2 match

Match a sub condition using the value in a hash

=cut

sub match {
    my ($self, $arg, $mac) = @_;
    return $FALSE unless defined $mac;
    return $FALSE unless defined $arg && reftype ($arg) eq 'HASH';
    my $key = $self->key;
    unless (exists $arg->{$key}) {
        $arg->{$key} = extended_node_get_data($mac, $key);
    }
    return $self->SUPER::match($arg);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
