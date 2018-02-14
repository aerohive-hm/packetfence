package pf::Switch::Extreme::Summit;

=head1 NAME

pf::Switch::Extreme::Summit - Object oriented module to parse SNMP traps and 
manage Extreme Networks' Summit switches

=head1 STATUS

This module is currently only a placeholder, see pf::Switch::Extreme.

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Extreme');

sub description { 'ExtremeNet Summit series' }

# importing switch constants
use pf::Switch::constants;
use pf::util;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
