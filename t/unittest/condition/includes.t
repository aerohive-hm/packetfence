=head1 NAME

profile/filter/includes.t

=cut

=head1 DESCRIPTION

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

use_ok("pf::condition::includes");

my $filter = new_ok ( "pf::condition::includes", [value => 'test'],"Test include based filter");

ok($filter->match(['test','testing123']),"filter matches");

ok(!$filter->match(['desting','testing123']),"filter does not match when it's doesn't include element");

ok(!$filter->match(undef),"value undef does not match filter");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


