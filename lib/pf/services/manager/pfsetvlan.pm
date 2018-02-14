package pf::services::manager::pfsetvlan;
=head1 NAME

pf::services::manager::pfsetvlan add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::pfsetvlan

=cut

use strict;
use warnings;
use Moo;
extends 'pf::services::manager';

has '+name' => (default => sub { 'pfsetvlan' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

