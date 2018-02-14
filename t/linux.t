#!/usr/bin/perl

=head1 NAME

linux.t

=head1 DESCRIPTION

Linux tests

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

use pf::util;

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger('linux.t');

ok(defined(get_total_system_memory()), "fetch total system memory");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

