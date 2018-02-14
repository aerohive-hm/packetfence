=head1 NAME

t::unittest::switch_groups

=cut

=head1 DESCRIPTION

unit tests for Switch groups

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

use pf::node;
use Test::More tests => 8;

#This test will running last
use Test::NoWarnings;

use pf::SwitchFactory;

my $switch;

$switch = pf::SwitchFactory->instantiate("172.16.8.21" );
ok($switch, "Can instantiate a switch member of a group");

is($switch->{_type}, "Meraki::MR",
    "Type is properly inherited from group");

is($switch->{_defaultVlan}, -1,
    "defaultVlan is properly inherited from group");

is($switch->{_customVlan1}, "patate",
    "customVlan1 is properly inherited from default");

$switch = pf::SwitchFactory->instantiate("172.16.8.23");

is($switch->{_type}, "Meraki::MR",
    "Type is properly inherited from group");

is($switch->{_defaultVlan}, 42,
    "defaultVlan is properly defined when set directly in a group member");

$switch = pf::SwitchFactory->instantiate("172.16.3.2");

is($switch->{_customVlan1}, "patate",
    "Inheritance through default switch still works");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

