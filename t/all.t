#!/usr/bin/perl -w

=head1 NAME

all.t

=head1 DESCRIPTION

Test suite for all tests.

=cut

use strict;
use warnings;
use diagnostics;

use Test::Harness;

use lib qw(/usr/local/pf/t);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}
use TestUtils;

# trying to run tests in order were they provide most bang for the buck
runtests(
    @TestUtils::compile_tests,
    @TestUtils::unit_tests,
    @TestUtils::unit_failing_tests,
    @TestUtils::cli_tests,
    @TestUtils::dao_tests,
    @TestUtils::quality_tests,
    @TestUtils::quality_failing_tests,
    @TestUtils::integration_tests,
);

# TODO pfdetect_remote tests

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut
