package pf::cmd::pf::floatingnetworkdeviceconfig;
=head1 NAME

pf::cmd::pf::floatingnetworkdeviceconfig add documentation

=head1 SYNOPSIS

 pfcmd floatingnetworkdeviceconfig get <all|floatingnetworkdevice>
       pfcmd floatingnetworkdeviceconfig add <floatingnetworkdevice> [assignments]
       pfcmd floatingnetworkdeviceconfig edit <floatingnetworkdevice> [assignments]
       pfcmd floatingnetworkdeviceconfig delete <floatingnetworkdevice>

query/modify floating_network_device.conf configuration file

=head1 DESCRIPTION

pf::cmd::pf::floatingnetworkdeviceconfig

=cut

use strict;
use warnings;
use pf::ConfigStore::FloatingDevice;
use base qw(pf::base::cmd::config_store);

sub configStoreName { "pf::ConfigStore::FloatingDevice" }

sub display_fields { qw(floatingnetworkdevice ip trunkPort pvid taggedVlan) }

sub idKey { 'floatingnetworkdevice' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

