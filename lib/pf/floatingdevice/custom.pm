package pf::floatingdevice::custom;

=head1 NAME

pf::floatingdevice::custom - custom module to manage the floating network devices.

=head1 SYNOPSIS

pf::floatingdevice::custom contains the functions necessary to manage the 
floating network devices. A floating network device is a device that 
PacketFence does not manage as a regular device.

This modules extends pf::floatingdevice. Override methods for which you want 
to customize behavior here.

=cut

use strict;
use warnings;

use base ('pf::floatingdevice');

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
