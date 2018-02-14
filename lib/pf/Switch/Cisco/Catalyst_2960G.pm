package pf::Switch::Cisco::Catalyst_2960G;
=head1 NAME

pf::Switch::Cisco::Catalyst_2960G

=head1 DESCRIPTION

Object oriented module to access and configure Cisco Catalyst 2960G switches

=head1 STATUS

This module is currently only a placeholder, see L<pf::Switch::Cisco::Cisco_2960> for relevant support items.

This module implement support for a different ifIndex translation for the 2960G.

=head1 BUGS AND LIMITATIONS

Most of the code is shared with the 2960 make sure to check the BUGS AND
LIMITATIONS section of L<pf::Switch::Cisco::Catalyst_2960>.

=cut

use strict;
use warnings;

use pf::log;
use Net::SNMP;

use base ('pf::Switch::Cisco::Catalyst_2960');

sub description { 'Cisco Catalyst 2960G' }

# CAPABILITIES
# inherited from 2960

=head1 METHODS

=over

=item NasPortToIfIndex

Translate RADIUS NAS-Port into switch's ifIndex.

=cut

sub NasPortToIfIndex {
    my ($self, $NAS_port) = @_;
    my $logger = get_logger();

    # ex: 50023 is ifIndex 10123
    if ($NAS_port =~ s/^500/101/) {
        return $NAS_port;
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
