=head1 NAME

Tests for pf::condition::matches

=cut

=head1 DESCRIPTION

Tests for pf::condition::matches

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

use_ok("pf::condition::matches");

my $filter = new_ok ( "pf::condition::matches", [value => 'test'],"Test regex based filter");

ok($filter->match('testing123'),"filter matches");

ok(!$filter->match('desting'),"filter does not match matches");

ok(!$filter->match(undef),"value undef does not match filter");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


