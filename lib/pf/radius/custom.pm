package pf::radius::custom;

=head1 NAME

pf::radius::custom - Module that deals with everything RADIUS related

=head1 SYNOPSIS

The pf::radius module contains the functions necessary for answering RADIUS queries.
RADIUS is the network access component known as AAA used in 802.1x, MAC authentication, etc.
This module acts as a proxy between our FreeRADIUS perl module's SOAP requests
(packetfence.pm) and PacketFence core modules.

This modules extends pf::radius. Override methods for which you want to customize
behavior here.

=cut

use strict;
use warnings;

use base ('pf::radius');
use pf::config qw($ROLE_API_LEVEL);
use pf::locationlog;
use pf::node;
use pf::Switch;
use pf::SwitchFactory;
use pf::util;
use pf::role::custom $ROLE_API_LEVEL;
# constants used by this module are provided by
use pf::radius::constants;

our $VERSION = 1.03;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
