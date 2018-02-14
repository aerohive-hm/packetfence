package pf::cmd::pf::networkconfig;
=head1 NAME

pf::cmd::pf::networkconfig add documentation

=head1 SYNOPSIS

 pfcmd networkconfig get <all|network>
       pfcmd networkconfig add <network> [assignments]
       pfcmd networkconfig edit <network> [assignments]
       pfcmd networkconfig delete <network>

query/modify networks.conf configuration file

=head1 DESCRIPTION

pf::cmd::pf::networkconfig

=cut

use strict;
use warnings;
use pf::ConfigStore::Network;
use base qw(pf::base::cmd::config_store);

sub configStoreName { "pf::ConfigStore::Network" }

sub display_fields { qw(network type named dhcpd netmask gateway next_hop domain-name dns dhcp_start dhcp_end dhcp_default_lease_time dhcp_max_lease_time) }

sub idKey { 'network' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

