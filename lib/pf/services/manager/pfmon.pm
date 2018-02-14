package pf::services::manager::pfmon;
=head1 NAME

pf::services::manager::pfmon add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::pfmon

=cut

use strict;
use warnings;
use Moo;
use pf::cluster;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfmon' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
