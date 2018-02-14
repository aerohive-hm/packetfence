package pf::Switch::HP::Procurve_3400cl;

=head1 NAME

pf::Switch::HP::Procurve_3400cl - Object oriented module to parse SNMP traps and manage HP Procurve 3400cl switches

=head1 STATUS

This switch was reported to work by the community with the Procurve 2600 module.

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::HP');

sub description { 'HP ProCurve 3400cl Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
