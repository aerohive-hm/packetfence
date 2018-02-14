
=head1 NAME

example pf test

=cut

=head1 DESCRIPTION

example pf test script

=cut

use strict;
use warnings;
#
use lib qw(/root/code/packetfence/lib );
use pf::role;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t /root/code/packetfence/t);

    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 6;

#This test will running last
#use Test::NoWarnings;
my $mac = '00:12:f0:13:32:BA';

my $node_info = {
    bypass_vlan => 1,
    bypass_role => "default"
};

is( pf::role::_check_bypass($mac, $node_info),
    ( 1, "default" ),
    "check_bypass returns the bypass_vlan and bypass_role"
);

$node_info = {
    bypass_role => "default"
};

is( pf::role::_check_bypass($mac, $node_info),
    ( undef, "default" ),
    "check_bypass returns the undef bypass_vlan and bypass_role"
);

$node_info = {
    bypass_vlan => 1,
};

is( pf::role::_check_bypass($mac, $node_info),
    ( 1, undef ),
    "check_bypass returns the bypass_vlan and undef bypass_role"
);

$node_info = {
};

is( pf::role::_check_bypass($mac, $node_info),
    ( undef, undef ),
    "check_bypass returns the undef bypass_vlan and undef bypass_role"
);

undef $node_info; 
is( pf::role::_check_bypass($mac, $node_info),
    ( undef, undef ),
    "check_bypass returns the undef bypass_vlan and undef bypass_role when passed undef node_info"
);

undef $mac;
is( pf::role::_check_bypass($mac, $node_info),
    ( undef, undef ),
    "check_bypass returns the undef bypass_vlan and undef bypass_role when passed undef mac"
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
