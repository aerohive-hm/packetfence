#!/usr/bin/perl

=head1 NAME

AdminRoles

=cut

=head1 DESCRIPTION

unit test for AdminRoles

=cut

use strict;
use warnings;
#
use lib qw(
    /usr/local/pf/lib
);

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 10;
use Test::Mojo;

#This test will running last
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

my $collection_base_url = '/api/v1/config/admin_roles';

my $base_url = '/api/v1/config/admin_role';

$t->get_ok($collection_base_url)
  ->status_is(200);

$t->post_ok($collection_base_url => json => {})
  ->status_is(422);

$t->post_ok($collection_base_url, {'Content-Type' => 'application/json'} => '{')
  ->status_is(400);

$t->get_ok("$base_url/User Manager")
  ->status_is(200)
  ->json_is('/item/id', 'User Manager');



=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

