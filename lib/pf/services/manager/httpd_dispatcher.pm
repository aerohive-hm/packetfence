package pf::services::manager::httpd_dispatcher;

=head1 NAME

pf::services::manager::httpd_dispatcher

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_dispatcher

=cut

use strict;
use warnings;
use Moo;

extends 'pf::services::manager';

has '+name' => (default => sub { 'httpd.dispatcher' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

