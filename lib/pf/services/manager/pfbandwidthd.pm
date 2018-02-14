package pf::services::manager::pfbandwidthd;
=head1 NAME

pf::services::manager::pfbandwidthd add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::pfbandwidthd

=cut

use strict;
use warnings;
use Moo;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfbandwidthd' } );

sub _cmdLine { my $self = shift; $self->executable ; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

