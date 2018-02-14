package pf::services::manager::pfdhcplistener;
=head1 NAME

pf::services::manager::pfdhcplistener add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::pfdhcplistener

=cut

use strict;
use warnings;
use Moo;
use pf::log;
use pf::config qw(%Config);
use pf::util;

extends 'pf::services::manager';

has '+name' => (default => sub { 'pfdhcplistener'} );

sub isManaged {
    my ($self) = @_;
    return isenabled($Config{'network'}{'dhcpdetector'}) && $self->SUPER::isManaged();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

