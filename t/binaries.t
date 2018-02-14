#!/usr/bin/perl
=head1 NAME

binaries.t

=head1 DESCRIPTION

Compile check on perl binaries

=cut

use strict;
use warnings;


our $jobs;

BEGIN {
    $jobs = $ENV{'PF_SMOKE_TEST_JOBS'} || 6;
}

use Test::More;
use Test::ParallelSubtest max_parallel => $jobs;
use Test::NoWarnings;

BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}
use TestUtils qw(get_all_perl_binaries get_all_perl_cgi);

my @binaries = (
    get_all_perl_binaries(),
    get_all_perl_cgi()
);

# all files + no warnings
plan tests => scalar @binaries * 1 + 1;

foreach my $current_binary (@binaries) {
    my $flags = '-I/usr/local/pf/t -Mtest_paths';
    if ($current_binary =~ m#/usr/local/pf/bin/pfcmd\.pl#) {
        $flags .= ' -T';
    }
    bg_subtest "$current_binary" => sub {
        plan tests => 1;
        is( system("/usr/bin/perl $flags -c $current_binary 2>&1"), 0, "$current_binary compiles" );
    };
}

bg_subtest_wait();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

