package pf::Switch::AlliedTelesis;

=head1 NAME

pf::Switch::AlliedTelesis - Object oriented module to access SNMP enabled AliedTelesis Switches

=head1 SYNOPSIS

The pf::Switch::AlliedTelesis module implements an object oriented interface
to access SNMP enabled AlliedTelesis switches.

=head1 STATUS

=over

=item Supports

=over

=item 802.1X/Mac Authentication without VoIP

=back

Stacked switch support has not been tested.

=back

Tested on a AT8000GS with firmware 2.0.0.26.

=head1 BUGS AND LIMITATIONS

The minimum required firmware version is 2.0.0.26.

Dynamic VLAN assignment on ports with voice is not supported by vendor.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch');

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
    my $oid_alliedFirmwareVersion = '.1.3.6.1.4.1.89.2.4.0';
    my $logger = $self->logger;
    if ( !$self->connectRead() ) {
        return '';
    }
    $logger->trace(
        "SNMP get_request for oid_alliedFirmwareVersion: $oid_alliedFirmwareVersion"
    );
    my $result = $self->{_sessionRead}->get_request( -varbindlist => [$oid_alliedFirmwareVersion] );
    my $runtimeSwVersion = ( $result->{$oid_alliedFirmwareVersion} || '' );

    return $runtimeSwVersion;
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
