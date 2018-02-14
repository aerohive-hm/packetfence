package pf::condition::node_extended;

=head1 NAME

pf::condition::node_extended -

=cut

=head1 DESCRIPTION

pf::condition::node_extended

=cut

use strict;
use warnings;
use Moose;
use pf::constants qw($TRUE $FALSE);
extends qw(pf::condition::key);
use Scalar::Util qw(reftype);

=head2 match

The root condition for extended node data

=cut

sub match {
    my ($self, $arg) = @_;
    return $FALSE unless defined $arg && reftype ($arg) eq 'HASH';
    return $FALSE unless exists $arg->{mac} && defined $arg->{mac};
    my $key = $self->key;
    unless (exists $arg->{$key}) {
        $arg->{$key} = {};
    }
    return $self->condition->match($arg->{$key}, $arg->{mac});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
