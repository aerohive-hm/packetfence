#!/usr/bin/perl
=head1 NAME

test add documentation

=cut

=head1 DESCRIPTION

test

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);

use pf::radius::soapclient;
use pf::api::jsonrpcclient;
use pf::api::msgpackclient;
use Data::Dumper;
use Benchmark;

our %DATA = (
   'User-Name' => "10683f71d750",
   'User-Password' => "10683f71d750",
   'Called-Station-Id' => "9C-1C-12-C2-A2-E8:OpenWrt-OPEN",
   'NAS-Port-Type' => 'Wireless-802.11',
   'NAS-Port' => 0,
   'Calling-Station-Id' => "10-68-3F-71-D7-50",
   'Connect-Info' => "CONNECT 11Mbps 802.11b",
   'Message-Authenticator' => "0x5f44baee6673fd097e6c649363e4876d",
);

our @DATA = ( 1 .. 1000);

timethese(-10, {
    send_msgpack_request => sub { pf::api::msgpackclient->new->call(echo => (\%DATA)) },
    send_json_request => sub { pf::api::jsonrpcclient->new->call(echo => (\%DATA)) },
    send_soap_request => sub { send_soap_request('echo',\%DATA) },
    }
);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

