package pf::Switch::Enterasys::SecureStack_C2;

=head1 NAME

pf::Switch::Enterasys::SecureStack_C2 - Object oriented module to access SNMP enabled Enterasys SecureStack C2 switches

=head1 SYNOPSIS

The pf::Switch::Enterasys::SecureStack_C2 module implements an object 
oriented interface to access SNMP enabled Enterasys SecureStack C2 switches.

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Enterasys');

sub description { 'Enterasys SecureStack C2' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
