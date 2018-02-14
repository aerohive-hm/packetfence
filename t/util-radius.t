#!/usr/bin/perl
=head1 NAME

util-radius.t

=head1 DESCRIPTION

pf::util::radius module tests

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 2;
use Test::NoWarnings;

=head1 Tests

=cut

use_ok('pf::util::radius');

# TODO: we have integration tests in stress-test/ {coa-calls.pl, coa-server.pl} but nothing automated.

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

