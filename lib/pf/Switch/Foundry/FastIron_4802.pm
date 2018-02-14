package pf::Switch::Foundry::FastIron_4802;

=head1 NAME

pf::Switch::Foundry::FastIron_4802 - Object oriented module to access SNMP
enabled Foundry FastIron 4802 switches

=head1 SYNOPSIS

The pf::Switch::Foundry::FastIron_4802 module implements an object 
oriented interface to access SNMP enabled Foundry FastIron 4802 switches.

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Foundry');

sub description { 'Foundry FastIron 4802' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
