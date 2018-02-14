package pf::services::manager::pfsso;

=head1 NAME

pf::services::manager::pfsso - The service manager for the pfsso  service

=cut

=head1 DESCRIPTION

pf::services::manager::pfsso

=cut

use strict;
use warnings;
use Moo;
use pf::cluster;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfsso' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
