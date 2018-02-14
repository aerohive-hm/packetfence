package pf::option82;

=head1 NAME

pf::option82 - module for option82 management.

=cut

=head1 DESCRIPTION

pf::option82 contains task to be able to use the dhcp option 82.

=head1 CONFIGURATION AND ENVIRONMENT

Read the F<pf.conf> configuration file.

=cut

use strict;
use warnings;
use pf::log;
use pf::CHI;
use pf::SwitchFactory;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT_OK );
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
        search_switch
        get_switch_from_option82
    );
}

our $OPTION82_PREFIX = 'option82:';

=head2 search_switch

Return the ip address of the switch that match the mac address on option 82 in dhcp packet

=cut

sub search_switch {
    my $logger = pf::log::get_logger();
    $logger->info("map switch mac address to switch_id for option 82");
    my $cache = pf::CHI->new( namespace => 'switch' );
    foreach my $switch_id ( grep { $_ ne 'default' } keys %pf::SwitchFactory::SwitchConfig ) {
        my $switch = pf::SwitchFactory->instantiate($switch_id);
        my $switch_mac = $switch->getRelayAgentInfoOptRemoteIdSub() if defined($switch->{'_switchIp'});
        $cache->set("${OPTION82_PREFIX}${switch_mac}", $switch_id) if defined($switch_mac);
    }
}

=head2 get_switch_from_option82

find the switch from the option82

=cut

sub get_switch_from_option82 {
    my($mac) = @_;
    my $cache = pf::CHI->new( namespace => 'switch' );
    return $cache->get("${OPTION82_PREFIX}${mac}");
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
