package pf::roles::custom;

=head1 NAME

pf::roles::custom - OO module that performs the roles lookups for nodes

=head1 SYNOPSIS

The pf::roles::custom implements roles lookups for nodes that are custom to a particular setup. 

This module extends pf::roles

=head1 EXPERIMENTAL

This module is considered experimental. For example not a lot of information
is provided to make the role decisions. This is expected to change in the
future at the cost of API changes.

You have been warned!

=cut

use strict;
use warnings;


use base ('pf::roles');
use pf::config;
use pf::node qw(node_attributes);
use pf::violation qw(violation_count_reevaluate_access);

our $VERSION = 0.90;

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
