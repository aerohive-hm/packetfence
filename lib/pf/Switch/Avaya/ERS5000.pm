package pf::Switch::Avaya::ERS5000;

=head1 NAME

pf::Switch::Avaya::ERS5000 - Object oriented module to access SNMP enabled Avaya ERS5000 switches

=head1 SYNOPSIS

The pf::Switch::Avaya::ERS5000 module implements an object 
oriented interface to access SNMP enabled Avaya::ERS5000 switches.

=head1 STATUS

This module is currently only a placeholder, see pf::SNMP::Avaya.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Avaya');

sub description { 'Avaya ERS 5000 Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
