package pf::Switch::Dlink::DGS_3200;

=head1 NAME

pf::Switch::Dlink::DGS_3200 - Object oriented module to access SNMP enabled Dlink DES 3100 switches

=head1 SYNOPSIS

The pf::Switch::Dlink::DGS_3200 module implements an object oriented interface
to access SNMP enabled Dlink DGS 3200 switches.

=head1 STATUS

=over

=item Supports

=over

=item 802.1X/Mac Authentication without VoIP

=back

=back

=head1 BUGS AND LIMITATIONS

The minimum required firmware version is 2.00.012 to properly support MAC Authentication

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Dlink');

sub description { 'D-Link DGS 3200' }

# importing switch constants
use pf::Switch::constants;
use pf::util;
use pf::constants;
use pf::config qw(
    $MAC
    $PORT
);

=head1 SUBROUTINES

=over

=cut

# CAPABILITIES
# access technology supported
sub supportsWiredMacAuth { return $TRUE; }
sub supportsWiredDot1x { return $TRUE; }
# inline capabilities
sub inlineCapabilities { return ($MAC,$PORT); }

=item getVersion

=cut

sub getVersion {
    my ($self) = @_;
    my $oid_dlinkFirmwareVersion = '1.3.6.1.4.1.171.10.94.89.89.2.4.0';
    my $logger = $self->logger;
    if ( !$self->connectRead() ) {
        return '';
    }
    $logger->trace(
        "SNMP get_request for oid_dlinkFirmwareVersion: $oid_dlinkFirmwareVersion"
    );
    my $result = $self->{_sessionRead}->get_request( -varbindlist => [$oid_dlinkFirmwareVersion] );
    my $runtimeSwVersion = ( $result->{$oid_dlinkFirmwareVersion} || '' );

    return $runtimeSwVersion;
}

=item NasPortToIfIndex

Translate RADIUS NAS-Port into the physical port ifIndex

=cut

sub NasPortToIfIndex {
    my ($self, $NAS_port) = @_;
    my $logger = $self->logger;

    #NAS-Port is ifIndex (Stacked switch not tested!!)
    return $NAS_port;
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
