package pf::constants::api;

=head1 NAME

pf::constants::api - constants for the API

=cut

=head1 DESCRIPTION

pf::constants::api

=cut

use strict;
use warnings;

use Readonly;

Readonly our $DEFAULT_CLIENT => "pf::api::jsonrpcclient";

our $PFSSO_PORT = 8777;
our $GO_DHCP_PORT = 22222;
our $GO_IPSET_PORT = 22223;

our $LOGIN_PATH = "/api/v1/login";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

