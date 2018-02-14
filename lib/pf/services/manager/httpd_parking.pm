package pf::services::manager::httpd_parking;

=head1 NAME

pf::services::manager::httpd_parking

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_parking

=cut

use strict;
use warnings;
use Moo;

extends 'pf::services::manager::httpd';

has '+name' => (default => sub { 'httpd.parking' } );


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
