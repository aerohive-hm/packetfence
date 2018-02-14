package pf::Switch::Cisco::Catalyst_3750;

=head1 NAME

pf::Switch::Cisco::Catalyst_3750

=head1 DESCRIPTION

Object oriented module to access and configure Cisco Catalyst 3750 switches

This module implements a few things but for the most part refer to L<pf::Switch::Cisco::Catalyst_2960>.

=head1 STATUS

Should work in:

=over

=item port-security

=item MAC-Authentication / 802.1X

We've got reports of it working with 12.2(55)SE.
Stacked switches should also work.

=back

The minimum required firmware version is 12.2(25)SEE2.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;

use Net::SNMP;

use pf::Switch::constants;

use base ('pf::Switch::Cisco::Catalyst_3560');

sub description { 'Cisco Catalyst 3750' }

# CAPABILITIES
# inherited from 3560

=head1 SUBROUTINES

=over

=item NasPortToIfIndex

Translate RADIUS NAS-Port into switch's ifIndex.

=cut

sub NasPortToIfIndex {
    my ($self, $NAS_port) = @_;
    my $logger = $self->logger;

    # NAS-Port bumps by +100 between stacks while ifIndex bumps by +500
    # some examples values for stacked switches are available in t/network-devices/cisco.t
    # This could work with other Cisco switches but we couldn't test so we implemented it only for the 3750.
    if (my ($stack_idx, $port) = $NAS_port =~ /^50(\d)(\d\d)$/) {
        return ( ($stack_idx - 1) * $CISCO::IFINDEX_PER_STACK ) + $port + $CISCO::IFINDEX_OFFSET;
    } else {
        $logger->warn("Unknown NAS-Port format. ifIndex translation could have failed. "
            ."VLAN re-assignment and switch/port accounting will be affected.");
    }
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
