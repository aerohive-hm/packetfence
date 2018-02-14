package pf::Switch::Nortel::BayStack5500_6x;

=head1 NAME

pf::Switch::Nortel::BayStack5500_6x

=head1 DESCRIPTION

Object oriented module to access SNMP enabled Nortel BayStack5500 switches running software code >= 6.x.

Starting with firmware 6.x ifIndex handling changed and this module takes care of this change.

=head1 STATUS

Aside from ifIndex handling this module is identical to pf::Switch::Nortel.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Nortel');

sub description { 'Nortel BayStack 5500 w/ firmware 6.x' }

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
