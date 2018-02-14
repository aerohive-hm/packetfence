package pf::Switch::Dlink::DES_3550;

=head1 NAME

pf::Switch::Dlink::DES_3550

=head1 SYNOPSIS

Object oriented module to access and manage Dlink DES 3550 switches

=head1 STATUS

Might support link-up link-down

Supports MAC Notification

This module is currently only a placeholder, see pf::Switch::Dlink

Tested by the community on the 5.01.B65 firmware.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Nortel');

sub description { 'D-Link DES 3550' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
