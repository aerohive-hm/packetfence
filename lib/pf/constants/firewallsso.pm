package pf::constants::firewallsso;

=head1 NAME

pf::constants::firewallsso - constants for firewallsso objects

=cut

=head1 DESCRIPTION

pf::constants::firewallsso

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw($SYSLOG_TRANSPORT $HTTP_TRANSPORT);

Readonly::Scalar our $SYSLOG_TRANSPORT => "syslog";
Readonly::Scalar our $HTTP_TRANSPORT => "http";

Readonly::Scalar our $FIREWALL_TYPES => [
    "BarracudaNG",
    "Checkpoint",
    "FortiGate",
    "Iboss",
    "PaloAlto",
    "WatchGuard",
    "JSONRPC",
];

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


