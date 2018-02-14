package pf::Switch::Cisco::WLC_5500;

=head1 NAME

pf::Switch::Cisco::WLC_5500 - Object oriented module to parse SNMP traps and 
manage Cisco Wireless Controllers 5500 Series

=head1 STATUS

This module is currently only a placeholder, see L<pf::Switch::Cisco::WLC> for relevant support items.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Cisco::WLC');

sub description { 'Cisco Wireless (WLC) 5500 Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
