package pf::Switch::Cisco::Aironet_1130;

=head1 NAME

pf::Switch::Cisco::Aironet_1130 - Object oriented module to access SNMP enabled Cisco Aironet 1130 APs

=head1 SYNOPSIS

The pf::Switch::Cisco::Aironet_1130 module implements an object oriented interface
to access SNMP enabled Cisco Aironet_1130 APs.

This modules extends pf::Switch::Cisco::Aironet

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::Cisco::Aironet');

sub description { 'Cisco Aironet 1130' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
