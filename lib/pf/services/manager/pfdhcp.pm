package pf::services::manager::pfdhcp;
=head1 NAME

pf::services::manager::pfdhcp

=cut

=head1 DESCRIPTION

pf::services::manager::pfdhcp

=cut

use strict;
use warnings;
use Moo;
use pf::cluster;
use pf::config qw(
    %Config
);
use pf::util;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfdhcp' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 inc.

=cut

1;
