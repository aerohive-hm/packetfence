package pf::Switch::Cisco::Catalyst_2900XL;

=head1 NAME

pf::Switch::Cisco::Catalyst_2900XL - Object oriented module to access SNMP enabled Cisco Catalyst 2900XL switches

=head1 SYNOPSIS

The pf::Switch::Cisco::Catalyst_2900XL module implements an object oriented interface
to access SNMP enabled Cisco::Catalyst_2900XL switches.

This modules extends pf::Switch::Cisco::Catalyst_3500XL

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::Cisco::Catalyst_3500XL');

sub description { 'Cisco Catalyst 2900XL Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
