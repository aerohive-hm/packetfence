package pf::services::manager::pfqueue;

=head1 NAME

pf::services::manager::pfqueue - Manager for the pfqueue service

=cut

=head1 DESCRIPTION

pf::services::manager::pfqueue

=cut

use strict;
use warnings;
use Moo;

extends 'pf::services::manager';

=head2 name

The name of service of this manager

=cut

has '+name' => ( default => sub { 'pfqueue' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
