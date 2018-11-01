#!/usr/bin/perl

=head1 NAME

tenant-no-db

=cut

=head1 DESCRIPTION

unit test for tenant-no-db

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

#This test will running last
use Test::NoWarnings;
use pf::tenant qw(
    tenant_view_by_name
    tenant_add
);

use pf::db;
my $tenant_name = "test_tenant_$$";
my $results = tenant_add({
    name => $tenant_name
});

pf::db::db_disconnect();
{
    no warnings qw(redefine);
    local $pf::db::DBH = undef;
    local *pf::db::db_connect = sub { undef };

    my $tenant = tenant_view_by_name($tenant_name);
    is($tenant, undef, "If the db cannot connect return undef");
}

my $tenant = tenant_view_by_name($tenant_name);

END {
    if ($tenant->{id}) {
        pf::dal::person->remove_items(
            -where => {
                tenant_id => $tenant->{id},
            }
        );
        pf::dal::tenant->remove_items(
            -where => {
                name => $tenant_name,
            }
        );
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

