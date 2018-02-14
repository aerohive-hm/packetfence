package pf::Switch::Amer::SS2R24i;

=head1 NAME

pf::Switch::Amer::SS2R24i - Object oriented module to access SNMP enabled Amer SS2R24i switches

=head1 SYNOPSIS

The pf::Switch::Amer::SS2R24i module implements an object oriented interface
to access SNMP enabled Amer::SS2R24i switches.

=head1 STATUS

This module is currently only a placeholder, all the logic resides in Amer.pm

Currently only supports linkUp / linkDown mode

Developed and tested on SS2R24i running on firmware version 4.02-B15

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Amer');

sub description { 'Amer SS2R24i' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
