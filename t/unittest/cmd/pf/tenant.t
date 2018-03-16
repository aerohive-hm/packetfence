#!/usr/bin/perl

=head1 NAME

tenant

=cut

=head1 DESCRIPTION

unit test for tenant

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

use pf::cmd::pf::tenant;
use Test::More tests => 5;

#This test will running last
use Test::NoWarnings;
use pf::dal::tenant;
use pf::error qw(is_success);

my $tenant_name = "test_$$";

my $cmd = "perl -T -I/usr/local/pf/t -Msetup_test_config /usr/local/pf/bin/pfcmd.pl tenant add $tenant_name";
system($cmd);

is($?, 0, "Adding tenant $tenant_name via pfcmd succeeded");

my ($status, $iter) = pf::dal::tenant->search(
    -where => {
        name => $tenant_name,
    },
    -with_class => undef,
);

ok(is_success($status), "Query was for tenant was succcessful");

my $tenant = $iter->next;

is($tenant_name, $tenant->{name},  "$tenant_name was really added to the database");

{
    local $? = $?;
    system($cmd);
    ok($? != 0, "Adding tenant $tenant_name twice via pfcmd failed");
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

