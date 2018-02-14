package pf::Switch::Cisco::Catalyst_4500;

=head1 NAME

pf::Switch::Cisco::Catalyst_4500 - Object oriented module to access and configure Cisco Catalyst 4500 switches

=head1 STATUS

This module is currently only a placeholder, see pf::Switch::Cisco::Catalyst_2960.

We do not know the minimum required firmware version.

=head1 BUGS AND LIMITATIONS

Because a lot of code is shared with the 2960 make sure to check the BUGS AND LIMITATIONS section of
L<pf::Switch::Cisco::Catalyst_2960> also.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::Cisco::Catalyst_2960');

sub description { 'Cisco Catalyst 4500 Series' }

=head2 getIfIndexByNasPortId

Fetch the ifindex on the switch by NAS-Port-Id radius attribute

=cut


sub getIfIndexByNasPortId {
    my ($self, $ifDesc_param) = @_;

    if ( !$self->connectRead() || !defined($ifDesc_param)) {
        return 0;
    }

    my $OID_ifDesc = '1.3.6.1.2.1.2.2.1.2';
    my $ifDescHashRef;
    my $cache = $self->cache;
    my $result = $cache->compute($self->{'_id'} . "-" . $OID_ifDesc, sub { $self->{_sessionRead}->get_table( -baseoid => $OID_ifDesc )});
    foreach my $key ( keys %{$result} ) {
        my $ifDesc = $result->{$key};
        if ( $ifDesc =~ /$ifDesc_param$/i ) {
            $key =~ /^$OID_ifDesc\.(\d+)$/;
            return $1;
        }
    }
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
