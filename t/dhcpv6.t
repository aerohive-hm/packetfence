#!/usr/bin/perl
#

=head1 NAME

t/dhcpv6.t - test script for parsing dhcpv6 packets

=cut

=head1 DESCRIPTION

test script for parsing dhcpv6 packets

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::util::dhcpv6;
use Net::Pcap qw(pcap_open_offline pcap_loop);
use Data::Dumper;
use bytes;


my @filenames = qw(dhcpv6-sample-1.pcap  dhcpv6-sample-2.pcap dhcpv6cap.pcapng);


foreach my $filename (@filenames) {
    my $err = '';
    my $pcap = pcap_open_offline("/usr/local/pf/t/data/$filename", \$err)
      or die "Can't read '$filename': $err\n";

    our $count = 1;
    my $data = \$count;

    my $value = pcap_loop($pcap, -1, \&process_packet, $data);

    sub process_packet {
        my ($user_data, $header, $packet) = @_;
        my ($eth_obj, $ip_obj, $udp_obj, $dhcp) = decompose_dhcpv6($packet);
        $dhcp->{count} = $$user_data;
        print Dumper($dhcp);
        $$user_data++;
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

