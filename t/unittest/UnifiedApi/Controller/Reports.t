#!/usr/bin/perl

=head1 NAME

Reports

=cut

=head1 DESCRIPTION

unit test for Reports

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

use Test::More tests => 135;
use Test::Mojo;

#This test will running last
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

$t->get_ok('/api/v1/reports/os' => json => { })
  ->json_has('/items/0/count')
  ->json_has('/items/0/description')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/os_active' => json => {  })
  ->json_has('/items/0/count')
  ->json_has('/items/0/description')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/os_all' => json => {  })
  ->json_has('/items/0/count')
  ->json_has('/items/0/description')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/osclass_active' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/osclass_all' => json => {  })
  ->json_has('/items/0/count')
  ->json_has('/items/0/description')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/inactive_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/active_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/unregistered_active' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/unregistered_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/registered_active' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/registered_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/unknownprints_active' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/unknownprints_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/statics_active' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/statics_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/openviolations_active' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/openviolations_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

$t->get_ok('/api/v1/reports/connectiontype' => json => {  })
  ->json_has('/items/0/connection_type')
  ->json_has('/items/0/connections')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/connectiontype_active' => json => {  })
  ->json_has('/items/0/connection_type')
  ->json_has('/items/0/connections')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/connectiontype_all' => json => {  })
  ->json_has('/items/0/connection_type')
  ->json_has('/items/0/connections')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/connectiontypereg_active' => json => {  })
  ->json_has('/items/0/connection_type')
  ->json_has('/items/0/connections')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/connectiontypereg_all' => json => {  })
  ->json_has('/items/0/connection_type')
  ->json_has('/items/0/connections')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/ssid' => json => {  })
  ->json_has('/items/0/nodes')
  ->json_has('/items/0/percent')
  ->json_has('/items/0/ssid')
  ->status_is(200);

$t->get_ok('/api/v1/reports/ssid_active' => json => {  })
  ->json_has('/items/0/nodes')
  ->json_has('/items/0/percent')
  ->json_has('/items/0/ssid')
  ->status_is(200);

$t->get_ok('/api/v1/reports/ssid_all' => json => {  })
  ->json_has('/items/0/nodes')
  ->json_has('/items/0/percent')
  ->json_has('/items/0/ssid')
  ->status_is(200);

$t->get_ok('/api/v1/reports/osclassbandwidth' => json => {  })
  ->json_has('/items/0/accttotal')
  ->json_has('/items/0/accttotaloctets')
  ->json_has('/items/0/dhcp_fingerprint')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/osclassbandwidth_all' => json => {  })
  ->json_has('/items/0/accttotal')
  ->json_has('/items/0/accttotaloctets')
  ->json_has('/items/0/dhcp_fingerprint')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/nodebandwidth' => json => {  })
  ->json_has('/items/0/acctinput')
  ->json_has('/items/0/acctinputoctets')
  ->json_has('/items/0/acctoutput')
  ->json_has('/items/0/acctoutputoctets')
  ->json_has('/items/0/accttotal')
  ->json_has('/items/0/accttotaloctets')
  ->json_has('/items/0/callingstationid')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/nodebandwidth_all' => json => {  })
  ->json_has('/items/0/acctinput')
  ->json_has('/items/0/acctinputoctets')
  ->json_has('/items/0/acctoutput')
  ->json_has('/items/0/acctoutputoctets')
  ->json_has('/items/0/accttotal')
  ->json_has('/items/0/accttotaloctets')
  ->json_has('/items/0/callingstationid')
  ->json_has('/items/0/percent')
  ->status_is(200);

$t->get_ok('/api/v1/reports/topsponsor_all' => json => {  })
  ->json_has('/items')
  ->status_is(200);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

