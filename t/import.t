#!/usr/bin/perl -w

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

BEGIN { use_ok('pf::import') }

# TODO add more tests, we should test:
# - import data/node-import-success.csv expect success
# - import data/node-import-fail-detect.csv expect a die
# - import data/node-import-fail-during.csv expect one warning on CLI output

# TODO potential integration tests (don't add here)
# - node_view unexistent
# - import
# - node_view that it exists

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

