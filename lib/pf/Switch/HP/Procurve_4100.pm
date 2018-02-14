package pf::Switch::HP::Procurve_4100;

=head1 NAME

pf::Switch::HP::Procurve_4100 - Object oriented module to access SNMP enabled HP Procurve 4100 switches

=head1 SYNOPSIS

The pf::Switch::HP::Procurve_4100 module implements an object 
oriented interface to access SNMP enabled HP Procurve 4100 switches.

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::HP::Procurve_2500');

sub description { 'HP ProCurve 4100 Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
