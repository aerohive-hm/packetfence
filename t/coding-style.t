#!/usr/bin/perl
=head1 NAME

coding-style.t

=head1 DESCRIPTION

Test validating coding style guidelines.

=cut

use strict;
use warnings;
use diagnostics;

use Test::More;
use Test::NoWarnings;
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use TestUtils qw(get_all_perl_binaries get_all_perl_cgi get_all_perl_modules);

my @files;

# TODO add our javascript to these tests
push(@files, TestUtils::get_all_perl_binaries());
push(@files, TestUtils::get_all_perl_cgi());
push(@files, grep {!m#addons/sourcefire/#}  TestUtils::get_all_perl_modules());

# all files + no warnings
plan tests => scalar @files * 1 + 1;

# lookout for TABS
foreach my $file (@files) {

    open(my $fh, '<', $file) or die "Can't open $file: $!";

    my $tabFound = 0;
    while (<$fh>) {
        if (/\t/) {
            $tabFound = 1;
        }
    }

    # I hate tabs!!
    ok(!$tabFound, "no tab character in $file");
}

# TODO test the tests for coding style but only if they are present
# (since they are not present in build system by default)

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

