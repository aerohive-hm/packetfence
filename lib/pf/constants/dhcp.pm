package pf::constants::dhcp;

=head1 NAME

pf::constants::dhcp - constants for dhcp

=cut

=head1 DESCRIPTION

pf::constants::dhcp

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw($DEFAULT_LEASE_LENGTH);

Readonly our $DEFAULT_LEASE_LENGTH => 86400;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

