=head1 NAME

Tests for pf::condition::network

=cut

=head1 DESCRIPTION

Tests for pf::condition::network

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}
use NetAddr::IP;

use Test::More tests => 9;                      # last test to print

use Test::NoWarnings;

use_ok("pf::condition::network");

my $filter = new_ok ( "pf::condition::network", [ value => '192.168.1.0/24'   ],"Test network based filter");

ok($filter->match('192.168.1.1' ),"filter matches");

ok(!$filter->match('192.168.2.1'),"filter does not match");

ok(!$filter->match( undef ),"last_ip undefined does not match");

ok(!$filter->match( '' ),"empty string does not match");

ok(!$filter->match( 'invalid ip' ),"invalid ip address string does not match");

ok(!$filter->match( 0 ),"invalid ip address number does not match");



=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


