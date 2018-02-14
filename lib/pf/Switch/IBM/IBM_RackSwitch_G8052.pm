package pf::Switch::IBM::IBM_RackSwitch_G8052;

=head1 NAME

pf::Switch::HP::RackSwitch_G8052 - Object oriented module to access and configure IBM RackSwitch G8052 switches

=head1 Firmware version

It has been tested on version 7.9.11.0

=head1 SUPPORTS

=head2 802.1X without VoiP

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::IBM');
use pf::constants;
use pf::config qw(
    $WIRED_802_1X
);
use pf::Switch::constants;
use pf::util;
use pf::node qw(node_attributes);

sub description { 'IBM RackSwitch G8052' }

# CAPABILITIES
# access technology supported
sub supportsWiredDot1x { return $TRUE; }
sub supportsRadiusDynamicVlanAssignment { return $TRUE; }

=head1 SUBROUTINES

=head2 wiredeauthTechniques

Return the reference to the deauth technique or the default deauth technique.

=cut

sub wiredeauthTechniques {
    my ($self, $method, $connection_type) = @_;
    my $logger = $self->logger;
    if ($connection_type == $WIRED_802_1X) {
        my $default = $SNMP::SNMP;
        my %tech = (
            $SNMP::SNMP => 'dot1xPortReauthenticate',
        );

        if (!defined($method) || !defined($tech{$method})) {
            $method = $default;
        }
        return $method,$tech{$method};
    }
}

=head2 _dot1xPortReauthenticate

=cut

sub _dot1xPortReauthenticate {
    my ($self, $ifIndex) = @_;
    my $logger = $self->logger;

    $logger->info("Trying to do IBM 802.1x port re-authentication.");

    my $oid_dot1xPaePortReauthenticate = "1.0.8802.1.1.1.1.1.2.1.5"; # from IEEE8021-PAE-MIB

    if (!$self->connectWrite()) {
        return 0;
    }

    $logger->trace("SNMP set_request force dot1xPaePortReauthenticate on ifIndex: $ifIndex");
    my $result = $self->{_sessionWrite}->set_request(-varbindlist => [
        "$oid_dot1xPaePortReauthenticate.$ifIndex", Net::SNMP::INTEGER, 1
    ]);

    if (!defined($result)) {
        $logger->error("got an SNMP error trying to force 802.1x re-authentication: ".$self->{_sessionWrite}->error);
    }

    return (defined($result));
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
