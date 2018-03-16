#!/usr/bin/perl

=head1 NAME

dal-set-tenant

=cut

=head1 DESCRIPTION

unit test for dal-set-tenant

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

use Test::More tests => 3;
use pf::dal;
use pf::dal::tenant;

#This test will running last
use Test::NoWarnings;

my $old_tentant_id = pf::dal->get_tenant;

my ($status, $iter) = pf::dal::tenant->search(
    -columns => ["MAX(id)|max_id"],
    -group_by => 'id',
    -with_class => undef,
);

my $data = $iter->next;

my $fake_tenant_id = $data->{max_id} + $$ + int(rand($$));

pf::dal->set_tenant(undef);

is($old_tentant_id, pf::dal->get_tenant, "Do not change tenant if it is undef");

pf::dal->set_tenant($fake_tenant_id);

isnt($fake_tenant_id, pf::dal->get_tenant, "Do not allow a non existent tenant_id to be set");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

