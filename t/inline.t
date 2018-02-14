#!/usr/bin/perl
=head1 NAME

inline.t

=head1 DESCRIPTION

pf::inline module testing

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 5;
use Test::MockModule;
use Test::MockObject::Extends;
use Test::NoWarnings;

use File::Basename qw(basename);

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger( basename($0) );
Log::Log4perl::MDC->put( 'proc', basename($0) );
Log::Log4perl::MDC->put( 'tid',  0 );

use pf::config;

BEGIN { 
    use_ok('pf::inline'); 
    use_ok('pf::inline::custom');
}

# test the object
my $inline_obj = new pf::inline::custom();
isa_ok($inline_obj, 'pf::inline');

# subs
can_ok($inline_obj, qw(
    fetchMarkForNode 
    performInlineEnforcement
    isInlineEnforcementRequired
));

# TODO more tests!

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

