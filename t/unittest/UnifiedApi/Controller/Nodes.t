#!/usr/bin/perl

=head1 NAME

Nodes

=cut

=head1 DESCRIPTION

unit test for Nodes

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';
use Date::Parse;
use pf::dal::node;
use pf::dal::locationlog;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;

}

#insert known data
#run tests
use Test::More tests => 32;
use Test::Mojo;
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

$t->get_ok('/api/v1/nodes')
  ->status_is(200);

$t->post_ok('/api/v1/nodes/search' => json => { fields => [qw(mac ip4log.ip)], query => { op=> 'equals', field => 'ip4log.ip', value => '1.2.2.3'  }  })
  ->status_is(200);

my $mac = "00:02:34:23:22:11";

$t->delete_ok("/api/v1/node/$mac");

$t->post_ok('/api/v1/nodes' => json => { mac => $mac })
  ->status_is(201);

$t->post_ok("/api/v1/node/$mac/register" => json => {   })
  ->status_is(204);

$t->post_ok("/api/v1/node/$mac/register" => json => { pid => 'default'  })
  ->status_is(204);

$t->post_ok("/api/v1/node/$mac/deregister" => json => { })
  ->status_is(204);

$t->get_ok("/api/v1/node/$mac/fingerbank_info" => json => {})
  ->status_is(200);

$t->post_ok("/api/v1/nodes/bulk_register" => json => { items => [$mac] })
  ->status_is(200)
  ->json_is('/items/0/mac', $mac)
  ->json_is('/items/0/status', 'success');

$t->post_ok("/api/v1/nodes/bulk_register" => json => { items => [$mac] })
  ->status_is(200)
  ->json_is('/items/0/mac', $mac)
  ->json_is('/items/0/status', 'skipped');

$t->post_ok('/api/v1/nodes/bulk_deregister' => json => { items => [$mac] })
  ->status_is(200)
  ->json_is('/items/0/mac', $mac)
  ->json_is('/items/0/status', 'success');

$t->post_ok('/api/v1/nodes/bulk_deregister' => json => { items => [$mac] })
  ->status_is(200)
  ->json_is('/items/0/mac', $mac)
  ->json_is('/items/0/status', 'skipped');

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
