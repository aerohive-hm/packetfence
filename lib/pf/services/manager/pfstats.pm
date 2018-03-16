package pf::services::manager::pfstats;
=head1 NAME

pf::services::manager::pfstats

=cut

=head1 DESCRIPTION

pf::services::manager::pfstats

=cut

use strict;
use warnings;
use Moo;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfstats' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 inc.

=cut

1;
