=head1 NAME

Tests for pf::condition::regex

=cut

=head1 DESCRIPTION

Tests for pf::condition::regex

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 7;                      # last test to print

use Test::NoWarnings;

use_ok("pf::condition::regex");

my $filter = new_ok ( "pf::condition::regex", [value => '^test'],"Test regex based filter");

ok($filter->match('testing123'),"filter regex");

ok(!$filter->match('desting'),"filter does not match regex");

ok(!$filter->match('atesting'),"filter does not match regex");

ok(!$filter->match(undef),"value undef does not match filter");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


