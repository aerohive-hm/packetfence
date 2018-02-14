package pf::Switch::HP::Procurve_5400;

=head1 NAME

pf::Switch::HP::Procurve_5400

=head1 SYNOPSIS

Module to manage HP Procurve 5400 switches

=head1 STATUS

=over

=item Supports

=over

=item linkUp / linkDown mode

=item port-security

=item MAC-Authentication

=item 802.1X

=back

=back

Has been reported to work on 5412zl by the community

=head1 BUGS AND LIMITATIONS

The code is the same as the 2500 but the configuration should be like the 4100 series.

Recommanded Firmware is K.15.06.0008

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::HP::Procurve_2500');

use pf::constants;
use pf::config qw(
    $MAC
    $PORT
);
use pf::Switch::constants;
use pf::util;

sub description { 'HP ProCurve 5400 Series' }

# CAPABILITIES
# access technology supported
sub supportsWiredMacAuth { return $TRUE; }
sub supportsWiredDot1x { return $TRUE; }
# VoIP technology supported
sub supportsRadiusVoip { return $TRUE; }
# inline capabilities
sub inlineCapabilities { return ($MAC,$PORT); }

#Insert your voice vlan name, not the ID.
our $VOICEVLANAME = "voip";

=over

=item getVoipVSA

Get Voice over IP RADIUS Vendor Specific Attribute (VSA).

TODO: Use Egress-VLANID instead. See: http://wiki.freeradius.org/HP#RFC+4675+%28multiple+tagged%2Funtagged+VLAN%29+Assignment

=cut

sub getVoipVsa {
    my ($self) = @_;
    my $logger = $self->logger;

    return ('Egress-VLAN-Name' => "1".$VOICEVLANAME);
}

=item isVoIPEnabled

Is VoIP enabled for this device

=cut

sub isVoIPEnabled {
    my ($self) = @_;
    return ( $self->{_VoIPEnabled} == 1 );
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
