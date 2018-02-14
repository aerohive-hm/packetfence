package pf::Switch::ThreeCom::E4800G;

=head1 NAME

pf::Switch::ThreeCom::E4800G

-head1 DESCRIPTION

Object oriented module to access and manage 3COM E4800G Switch

=head1 STATUS

=over

=item Supports

=over

=item 802.1X and MAC Authentication

=item linkUp / linkDown mode

=item port-security (broken! see L</"BUGS AND LIMITATIONS">)

=item VoIP

Voice over IP with MAC Auth / 802.1X could work but was not attempted.
Although current limitation regarding 802.1X re-authentication could imply lost calls on VLAN changes.

=back

=back

MAC-Authentication / 802.1X known to work with firmware V5.20 rel 2202P15 tested by the community.

=head1 BUGS AND LIMITATIONS

=over

=item Unclear NAS-Port to ifIndex translation

This switch's NAS-Port usage is not well documented or easy to guess
so we reversed engineered the translation for the 4200G but it might not apply well to other switches.
If it's your case, please let us know the NAS-Port you obtain in a RADIUS Request and the physical port you are on.
The consequence of a bad translation are that VLAN re-assignment (ie after registration) won't work.

=item Port-Security: security traps not sent under some circumstances

The 4200G exhibit a behavior where secureViolation traps are not sent
if the MAC has already been authorized on another port on the same VLAN.
This tend to happen a lot (when users move on the same switch) for this
reason we recommend not to use this switch in port-security mode.

This behavior has been confirmed on the 4800G using latest firmware (as of April 2011).

=item 802.1X Re-Authentication doesn't trigger a DHCP Request from the endpoint

Since this is critical for PacketFence's operation, as a work-around,
we decided to bounce the port which will force the client to re-authenticate and do DHCP.
Because of the port bounce PCs behind IP phones aren't recommended.
This behavior was experienced on a Windows 7 client on the 4200G with the latest firmware.

This behavior has not been confirmed or denied for this model.

=back

=head1 NOTES

=over

=item MAC Authentication and 802.1X behavior

Depending on your needs, you might want to use userlogin-secure-or-mac-ext instead of mac-else-userlogin-secure-ext.
In the former mode a 802.1X failure will leave the port unauthenticated and access will be denied.
In the latter mode, if 802.1X doesn't work then MAC Authentication is attempted.
It's really a matter of choice.

=back

=cut

use strict;
use warnings;

use base ('pf::Switch::ThreeCom::Switch_4200G');

sub description { '3COM E4800G' }

=head1 SUBROUTINES

=over

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
