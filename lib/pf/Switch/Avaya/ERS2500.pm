package pf::Switch::Avaya::ERS2500;

=head1 NAME

pf::Switch::Avaya::ERS2500 - Object oriented module to access SNMP enabled Avaya ERS2500 switches

=head1 SYNOPSIS

The pf::Switch::Avaya::ERS2500 module implements an object 
oriented interface to access SNMP enabled Avaya::ERS2500 switches.

=head1 STATUS

This module is currently only a placeholder, see L<pf::Switch::Avaya>.

Recommended firmware 4.3

=head1 BUGS AND LIMITATIONS

=over

=item ERS 25xx firmware 4.1

We received reports saying that port authorization / de-authorization in port-security did not work.
At this point we do not know exactly which firmwares are affected by the issue.

Firmware series 4.3 is apparently fine.

=back

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Avaya');

sub description { 'Avaya ERS 2500 Series' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
