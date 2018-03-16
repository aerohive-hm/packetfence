#!/usr/bin/perl

=head1 NAME

PortalModules

=cut

=head1 DESCRIPTION

unit test for PortalModules

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

use Test::More tests => 7;
use Test::Mojo;

#This test will running last
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

my $collection_base_url = '/api/v1/config/portal_modules';

my $base_url = '/api/v1/config/portal_module';

$t->get_ok($collection_base_url)
  ->status_is(200);

$t->post_ok($collection_base_url => json => {})
  ->status_is(422);

$t->post_ok($collection_base_url, {'Content-Type' => 'application/json'} => '{')
  ->status_is(400);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

