#!/usr/bin/perl
=head1 NAME

Group

=cut

=head1 DESCRIPTION

Group

=cut

use strict;
use warnings;

use Test::More tests => 10;

use Test::NoWarnings;
BEGIN {
    use lib qw(/usr/local/pf/t /usr/local/pf/lib);
    use setup_test_config;
}


use_ok("ConfigStore::HierarchyTest");

my $config = new_ok("ConfigStore::HierarchyTest",[configFile => './data/hierarchy.conf']);

is_deeply($config->fullConfig("group default"), { param1 => "value1", param2 => "value2" },
    "Default group hierarchy is properly detected");

is_deeply($config->fullConfig("group group1"), { param1 => "group1", param2 => "value2" },
    "group1 hierarchy is properly detected");

is_deeply($config->fullConfig("group group2"), { param1 => "value1", param2 => "group2" },
    "group2 hierarchy is properly detected");

is_deeply($config->fullConfig("element"), { param1 => "value1", param2 => "value2" },
    "element hierarchy is properly detected");

is_deeply($config->fullConfig("element1"), { group => "group1", param1 => "group1", param2 => "value2" },
    "element1 hierarchy is properly detected");

is_deeply($config->fullConfig("element2"), { group => "group2", param1 => "value1", param2 => "group2" },
    "element2 hierarchy is properly detected");

is_deeply($config->fullConfig("element3"), { group => "group1", param1 => "group1", param2 => "element3", param3 => "element3" },
    "element2 hierarchy is properly detected");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


