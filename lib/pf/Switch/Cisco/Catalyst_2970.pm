package pf::Switch::Cisco::Catalyst_2970;

=head1 NAME

pf::Switch::Cisco::Catalyst_2970 - Object oriented module to access and configure Cisco Catalyst 2970 switches

=head1 STATUS

This module is currently only a placeholder, see pf::Switch::Cisco::Catalyst_2960.

=head1 BUGS AND LIMITATIONS

Because a lot of code is shared with the 2960 make sure to check the BUGS AND LIMITATIONS section of 
L<pf::Switch::Cisco::Catalyst_2960> also.

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::Cisco::Catalyst_2960');

sub description { 'Cisco Catalyst 2970' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
