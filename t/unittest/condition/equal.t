=head1 NAME

Tests for pf::condition::equals

=cut

=head1 DESCRIPTION

Tests for pf::condition::equals

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 6;                      # last test to print

use Test::NoWarnings;

use_ok("pf::condition::equals");

my $filter = new_ok ( "pf::condition::equals", [value => 'test'],"Test pf::condition::equals constructor");

ok($filter->match('test'),"filter matches");

ok(!$filter->match('wrong_test'),"equal does not match filter");

ok(!$filter->match(undef ),"equal undef does not match filter");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


