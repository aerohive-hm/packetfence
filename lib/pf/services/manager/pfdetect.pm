package pf::services::manager::pfdetect;

=head1 NAME

pf::services::manager::pfdetect add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::pfdetect

=cut

use strict;
use warnings;
use Moo;
use pf::config qw(%ConfigDetect);;
extends 'pf::services::manager';

has '+name' => (default => sub { 'pfdetect' });

sub _cmdLine { my $self = shift; $self->executable; }

sub isManaged { keys(%ConfigDetect) > 0 }


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
