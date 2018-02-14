#!/usr/bin/perl
=head1 NAME

pfdhcplistener.t

=head1 DESCRIPTION

pfdhcplistener daemon tests

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 1;
use Test::NoWarnings;

use Log::Log4perl;
use File::Basename qw(basename);

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger( basename($0) );
Log::Log4perl::MDC->put( 'proc', basename($0) );
Log::Log4perl::MDC->put( 'tid',  0 );

# TODO move code out of pfdhcplistener into a module before we can test

# Testing error-handling
#is(pfdhcplistener::process_fingerprint($fakemac, ""), undef, "empty fingerprint returns undef");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

