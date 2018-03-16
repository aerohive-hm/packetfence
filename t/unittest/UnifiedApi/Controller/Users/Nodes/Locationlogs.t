#!/usr/bin/perl

=head1 NAME

Locationlogs

=cut

=head1 DESCRIPTION

unit test for Locationlogs

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

use Test::More tests => 14;
use Test::Mojo;

#This test will running last
use Test::NoWarnings;

my $t = Test::Mojo->new('pf::UnifiedApi');
my $test_mac = sprintf(
    "ff:ff:%02x:%02x:%02x:%02x",
    unpack("C4", pack("N", $$))
);

my $test_user = "test_user_$$";

$t->post_ok('/api/v1/users/' => json => {pid => $test_user})
  ->status_is(201)
  ->header_is('Location' => "/api/v1/user/$test_user");

my $location = $t->tx->res->headers->location;

$t->get_ok($location)
  ->status_is(200);

$t->post_ok("$location/nodes" => json => { mac => $test_mac } )
  ->status_is(201)
  ->header_is( 'Location' => "/api/v1/user/$test_user/node/$test_mac" );

$location = $t->tx->res->headers->location;

$t->post_ok("$location/locationlogs" => json => {})
  ->status_is(201)
  ->header_like('Location' => qr#^\Q$location\E/locationlog/[^/]+$#);

$location = $t->tx->res->headers->location;

$t->get_ok($location)
  ->status_is(200);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
