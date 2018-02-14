package pf::Switch::HP::Procurve_5300;

=head1 NAME

pf::Switch::HP::Procurve_5300 - Object oriented module to parse SNMP traps and manage HP Procurve 5300 switches

=head1 STATUS

This switch was reported to work by the community with the Procurve 5400 module with firmware 11.21.

This module is currently only a placeholder, see L<pf::Switch::HP::Procurve_5400> for relevant support items.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::HP::Procurve_5400');

sub description { 'HP ProCurve 5300 Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
