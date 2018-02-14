package pf::Switch::Nortel::BPS2000;

=head1 NAME

pf::Switch::Nortel::BPS2000 - Object oriented module to access SNMP enabled Nortel BPS2000 switches

=head1 SYNOPSIS

The pf::Switch::Nortel::BPS2000 module implements an object
oriented interface to access SNMP enabled Nortel::BPS2000 switches.

=head1 STATUS

BPS2000 switches don't support LLDP.

Otherwise this module is identical to pf::Switch::Nortel.

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::Nortel');

use pf::constants;
use pf::Switch::constants;
use pf::util;

sub description { 'Nortel BPS 2000' }

# special features
# LLDP is not available on BPS2000
sub supportsLldp { return $FALSE; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
