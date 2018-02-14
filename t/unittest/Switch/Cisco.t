=head1 NAME

Cisco

=cut

=head1 DESCRIPTION

unit test for Cisco

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 2;
use pf::Switch::Cisco;

#This test will running last
use Test::NoWarnings;

my $trapline = 'BEGIN TYPE 0 END TYPE BEGIN SUBTYPE 0 END SUBTYPE BEGIN VARIABLEBINDINGS .1.3.6.1.2.1.1.3.0 = Timeticks: (1088317706) 125 days, 23:06:17.06|.1.3.6.1.6.3.1.1.4.1.0 = OID: .1.3.6.1.4.1.9.9.315.0.0.1|.1.3.6.1.2.1.2.2.1.1.10120 = Wrong Type (should be INTEGER): Gauge32: 10120|.1.3.6.1.2.1.31.1.1.1.1.10120 = STRING: GigabitEthernet0/20|.1.3.6.1.4.1.9.9.315.1.2.1.1.10.10120 = Hex-STRING: 8C 73 6E FF 4E F9  END VARIABLEBINDINGS';

my $switch = pf::Switch::Cisco->new({ id => 'test'});

my $trap  = $switch->parseTrap($trapline);

is_deeply(
    $trap,
    {  
        trapType => 'secureMacAddrViolation',
        trapVlan => 0,
        trapMac => '8c:73:6e:ff:4e:f9',
        trapIfIndex => '10120'
    },
    "Test parsing trap line for secureMacAddrViolation"
);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

