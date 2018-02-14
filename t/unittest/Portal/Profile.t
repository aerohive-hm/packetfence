=head1 NAME

Test for the pf::Portal::Profile

=cut

=head1 DESCRIPTION

Test for the pf::Portal::Profile

=cut

use strict;
use warnings;

use lib '/usr/local/pf/lib';

use Test::More;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
    use_ok("pf::Connection::ProfileFactory");
}


my $profile = pf::Connection::ProfileFactory->instantiate("00:00:00:00:00:00", {});

is($profile->findScan("00:00:00:00:00:00", {device_type => "Microsoft Windows Kernel 6.0", category => "guest"})->{_id}, "test1",
    "Matching scan properly when OS + category match");

is($profile->findScan("00:00:00:00:00:00", {device_type => "Microsoft Windows Kernel 6.0", category => "dummy"})->{_id}, "test2",
    "Matching scan properly when scan defines only OS");

is($profile->findScan("00:00:00:00:00:00", {device_type => "Playstation 4", category => "guest"})->{_id}, "test3",
    "Matching scan properly when scan defines only category");

is($profile->findScan("00:00:00:00:00:00", {device_type => "Playstation 4", category => "dummy"})->{_id}, "test4",
    "Matching scan properly when scan defines no OS nor category");

is($profile->findScan("00:00:00:00:00:00", {device_type => undef, category => "guest"}), undef,
    "Shouldn't find a scan when there is no OS defined.");

is($profile->findProvisioner("00:00:00:00:00:00", {device_type => "Microsoft Windows Kernel 6.0", category => "guest"})->id, "deny1",
    "Matching provisioner properly when OS + category match");

is($profile->findProvisioner("00:00:00:00:00:00", {device_type => "Microsoft Windows Kernel 6.0", category => "dummy"})->id, "deny2",
    "Matching provisioner properly when provisioner defines only OS");

is($profile->findProvisioner("00:00:00:00:00:00", {device_type => "Playstation 4", category => "guest"})->id, "deny3",
    "Matching provisioner properly when provisioner defines only category");

is($profile->findProvisioner("00:00:00:00:00:00", {device_type => "Playstation 4", category => "dummy"})->id, "deny4",
    "Matching provisioner properly when provisioner defines no OS nor category");

is($profile->findProvisioner("00:00:00:00:00:00", {device_type => undef, category => "guest"}), undef,
    "Shouldn't find a provisioner when there is no OS defined.");

done_testing();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

