package pf::services::manager::pffilter;

=head1 NAME

pf::services::manager::pffilter - The service manager for the pffilter  service

=cut

=head1 DESCRIPTION

pf::services::manager::pffilter

=cut

use strict;
use warnings;
use Moo;
use pf::cluster;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pffilter' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
