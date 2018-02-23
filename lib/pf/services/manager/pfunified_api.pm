package pf::services::manager::pfunified_api;

=head1 NAME

pf::services::manager::pfunified_api -

=cut

=head1 DESCRIPTION

pf::services::manager::pfunified_api

=cut

use strict;
use warnings;
use Moo;
extends 'pf::services::manager';

has '+name' => (default => sub { 'pfunified_api' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

