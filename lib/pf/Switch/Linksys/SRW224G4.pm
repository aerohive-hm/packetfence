package pf::Switch::Linksys::SRW224G4;

=head1 NAME

pf::Switch::Linksys::SRW224G4 - Object oriented module to access SNMP enabled Linksys SRW224G4 switches

=head1 SYNOPSIS

The pf::Switch::Linksys::SRW224G4 module implements an object 
oriented interface to access SNMP enabled Linksys SRW224G4 switches.

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Linksys');

sub description { 'Linksys SRW224G4' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
