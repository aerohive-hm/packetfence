package pf::services::manager::api_frontend;

=head1 NAME

pf::services::manager::api_frontend - The service manager for the api_frontend  service

=cut

=head1 DESCRIPTION

pf::services::manager::api_frontend

=cut

use strict;
use warnings;
use Moo;
use pf::cluster;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'api-frontend' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2017 Inverse inc.

=cut

1;
