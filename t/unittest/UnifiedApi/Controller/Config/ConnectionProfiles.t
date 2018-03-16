#!/usr/bin/perl

=head1 NAME

ConnectionProfiles

=cut

=head1 DESCRIPTION

unit test for ConnectionProfiles

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

use Test::More tests => 17;
use Test::Mojo;

#This test will running last
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

my $collection_base_url = '/api/v1/config/connection_profiles';

my $base_url = '/api/v1/config/connection_profile';

$t->get_ok($collection_base_url)
  ->status_is(200)
  ->json_is('/items/0/id', 'default');

$t->get_ok("$base_url/default")
  ->status_is(200)
  ->json_is('/item/id', 'default');

$t->post_ok($collection_base_url => json => {})
  ->status_is(422);

$t->post_ok($collection_base_url => json => {id => 'default'})
  ->status_is(409);

$t->post_ok($collection_base_url, {'Content-Type' => 'application/json'} => '{')
  ->status_is(400);

$t->patch_ok("$base_url/default" => json => {})
  ->status_is(200);

$t->put_ok("$base_url/default" => json => {})
  ->status_is(422);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
