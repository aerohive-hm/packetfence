=head1 NAME

example pf test

=cut

=head1 DESCRIPTION

example pf test script

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';

use Test::More tests => 4;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use_ok('pf::factory::detect::parser');

my $alert = 'Mar  3 18:48:58 172.21.2.63 date=2014-03-03 time=18:49:15 devname=FortiGate-VM64 devid=FGVM010000016588 logid=0316013057 type=utm subtype=webfilter eventtype=ftgd_blk level=warning vd="root" policyid=1 identidx=0 sessionid=45421 osname="Windows" osversion="7 (x64)" srcip=172.21.5.11 srcport=2019 srcintf="port2" dstip=64.210.140.16 dstport=80 dstintf="port1" service="http" hostname="www.example.com" profiletype="Webfilter_Profile" profile="default" status="blocked" reqtype="referral" url="/test_adult_url" sentbyte=820 rcvdbyte=1448 msg="URL belongs to a category with warnings enabled" method=domain class=0 cat=14 catdesc="Pornography"';
 
my $parser = pf::factory::detect::parser->new('fortianalyser');
my $result = $parser->parse($alert);

is($result->{srcip}, "172.21.5.11");
is($result->{events}->{detect}, "0316013057");

#This test will running last
use Test::NoWarnings;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
