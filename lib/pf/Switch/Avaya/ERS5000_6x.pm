package pf::Switch::Avaya::ERS5000_6x;

=head1 NAME

pf::Switch::Avaya::ERS5000_6x

=head1 DESCRIPTION

Object oriented module to access SNMP enabled Avaya ERS5000 switches running software code >= 6.x.

Starting with firmware 6.x ifIndex handling changed and this module takes care of this change.

=head1 STATUS

Aside from ifIndex handling this module is identical to pf::SNMP::Avaya.

=head1 BUGS AND LIMITATIONS

There is a potential regresion when you use the ERS5500 switches with port-security on firmware 6.2.4.
If the switch is stacked, the trap will come with the wrong ifIndex number.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Avaya');

sub description { 'Avaya ERS 5000 Series w/ firmware 6.x' }

=head1 METHODS

TODO: This list is incomplete

=over

=item getBoardIndexWidth

How many ifIndex there is per board.
It changed with a firmware upgrade so it is encapsulated per switch module.

This module has 128.

=cut

sub getBoardIndexWidth {
    return 128;
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
