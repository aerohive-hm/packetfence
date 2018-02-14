=head1 NAME

Tests for pf::condition::date_before

=cut

=head1 DESCRIPTION

Tests for pf::condition::date_before

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 8;                      # last test to print

use Test::NoWarnings;

use_ok("pf::condition::date_before");

my $filter = new_ok ( "pf::condition::date_before", [value => '2034-10-28 13:37:42'],"Test pf::condition::date_before constructor with control date");

ok($filter->match('2015-11-27 13:49:42'), "given date is before control date");

ok(!$filter->match('2042-11-27 13:49:42'),"given date is not before control date");

$filter = new_ok ( "pf::condition::date_before", [],"Test pf::condition::date_before constructor without control date");

ok($filter->match('2015-11-27 13:49:42'), "given date is before control date");

ok(!$filter->match('2042-11-27 13:49:42'),"given date is not before control date");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


