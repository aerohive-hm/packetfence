package pf::inline::custom;

=head1 NAME

pf::inline - Object oriented module for inline enforcement related operations

=head1 SYNOPSIS

The pf::inline::custom module implements inline enforcement operations that are custom to a particular setup.

This module extends pf::inline

=cut

use strict;
use warnings;


use base ('pf::inline');
use pf::config;
use pf::iptables;
use pf::node qw(node_attributes);
use pf::violation qw(violation_count_reevaluate_access);

our $VERSION = 1.01;

=head1 SUBROUTINES

=over

=cut

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
