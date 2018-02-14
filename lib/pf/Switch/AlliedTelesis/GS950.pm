package pf::Switch::AlliedTelesis::GS950;

=head1 NAME

pf::Switch::AlliedTelesis::GS950

=head1 SYNOPSIS

Allied Telesis module for switches running the AT-S110 image

=head1 STATUS

Developed and tested on a GS950 running 'AT-S110 V2.0.2 (1.00.019)'

=head1 BUGS AND LIMITATIONS

=head2 MAB fallback does not work

There is no way to do 802.1x with MAB as a fallback method. It is either one or the other.

=head2 MAB uses EAP-MD5

The MAB uses EAP-MD5 which requires a FreeRADIUS policy to transform the EAP-MD5 request so PacketFence sees it as MAB.
See the Network Devices Configuration Guide for details on that.

=cut

use strict;
use warnings;

use base ('pf::Switch');

use pf::constants;

=head1 SUBROUTINES

=over

=cut

# Description
sub description { return "Allied Telesis GS950" }

# CAPABILITIES
# access technology supported
sub supportsWiredDot1x { return $TRUE; }
sub supportsWiredMacAuth { return $TRUE; }

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
