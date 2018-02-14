#!/usr/bin/perl -w
=head1 NAME

pfcmd.t

=head1 DESCRIPTION

Testing pfcmd command line interface (CLI)

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::NoWarnings;

use English '-no_match_vars';
use File::Basename qw(basename);
use Log::Log4perl;

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger( basename($0) );
Log::Log4perl::MDC->put( 'proc', basename($0) );
Log::Log4perl::MDC->put( 'tid',  0 );
our (@output,@main_args,$tests);
BEGIN {
    @output = `/usr/local/pf/bin/pfcmd.pl help`;
    foreach my $line (@output) {
        if ($line =~ /^ *([^ ]+) +\|/) {
            push @main_args, $1;
        }
    }
    $tests = 3 + scalar @main_args;
}


use Test::More tests => $tests;

=head1 TESTS

=over

=cut

=item command line help tests

=cut

foreach my $help_arg (@main_args) {
    my @output = `/usr/local/pf/bin/pfcmd.pl help $help_arg 2>&1`;
    like ( join('',@output), qr/^Usage:\s*pfcmd $help_arg/s,
         "pfcmd $help_arg is documented" );
}

=item exit status tests

=cut

# required to avoid warnings in admin guide asciidoc build
my @pfcmd_help = `/usr/local/pf/bin/pfcmd.pl help`;
is($CHILD_ERROR, 0, "pfcmd help exit with status 0");

# required to have help placed into the admin guide asciidoc during build
ok(@pfcmd_help, "pfcmd help outputs on STDOUT");

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

