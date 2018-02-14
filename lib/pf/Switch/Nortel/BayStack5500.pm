package pf::Switch::Nortel::BayStack5500;

=head1 NAME

pf::Switch::Nortel::BayStack5500 - Object oriented module to access SNMP enabled Nortel BayStack5500 switches

=head1 SYNOPSIS

The pf::Switch::Nortel::BayStack5500 module implements an object 
oriented interface to access SNMP enabled Nortel::BayStack5500 switches.

=head1 STATUS

This module is currently only a placeholder, see pf::Switch::Nortel.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Nortel');

sub description { 'Nortel BayStack 5500 Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
