#!/usr/bin/perl -w
=head1 NAME

dao/report.t

=head1 DESCRIPTION

Testing data access layer for the pf::pfcmd::report module

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 27;
use Test::NoWarnings;

use Log::Log4perl;

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger( "dao/report.t" );
Log::Log4perl::MDC->put( 'proc', "dao/report.t" );
Log::Log4perl::MDC->put( 'tid',  0 );

use lib qw(/usr/local/pf/t);
use TestUtils;

# override database connection settings to connect to test database
TestUtils::use_test_db();

BEGIN { use_ok('pf::pfcmd::report') }

my @methods = qw(
    report_os_all
    report_os_active
    report_osclass_all
    report_osclass_active
    report_active_all
    report_inactive_all
    report_unregistered_active
    report_unregistered_all
    report_active_reg
    report_registered_all
    report_registered_active
    report_openviolations_all
    report_openviolations_active
    report_statics_all
    report_statics_active
    report_unknownprints_all
    report_unknownprints_active
    report_connectiontype_all
    report_connectiontype_active
    report_connectiontypereg_all
    report_connectiontypereg_active
    report_ssid_all
    report_ssid_active
);

# Test each method, assume no warnings and results
{
    no strict 'refs';

    foreach my $method (@methods) {

        ok(defined(&{$method}()), "testing $method call");
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

