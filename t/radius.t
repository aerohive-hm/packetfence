#!/usr/bin/perl -w
=head1 NAME

radius.t

=head1 DESCRIPTION

pf::radius module testing

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use File::Basename qw(basename);
use Test::More tests => 5;
use Test::NoWarnings;

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger( basename($0) );
Log::Log4perl::MDC->put( 'proc', basename($0) );
Log::Log4perl::MDC->put( 'tid',  0 );

use pf::config;
use pf::radius::constants;

BEGIN {
    use_ok('pf::radius');
    use_ok('pf::radius::custom');
}

# test the object
my $radius = new pf::radius::custom();
isa_ok($radius, 'pf::radius');

# subs
can_ok($radius, qw(
    authorize
    _authorizeVoip
    _translateNasPortToIfIndex
    _isSwitchSupported
    _switchUnsupportedReply
));

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

