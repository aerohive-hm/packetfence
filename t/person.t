#!/usr/bin/perl -w

=head1 NAME

person.t

=head1 DESCRIPTION

Non-intrusive tests on pf::person

=cut

use strict;
use warnings;
use diagnostics;

use Test::More tests => 1;
use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}
BEGIN { use_ok('pf::person') }

# TODO really? That's it?

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

