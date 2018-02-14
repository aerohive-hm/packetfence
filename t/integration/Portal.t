#!/usr/bin/perl
=head1 NAME

Portal.t

=head1 DESCRIPTION

pf::Portal... subsystem integration testing

=cut

use strict;
use warnings;

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

BEGIN { 
    use_ok('pf::Portal::Session');
    use_ok('pf::Connection::ProfileFactory');
}

use pf::util;

=head1 TESTS

=over

=item Portal::Session

=cut

# test the object
my $portalSession = pf::Portal::Session->new();
isa_ok($portalSession, 'pf::Portal::Session');

# subs
can_ok($portalSession, qw(
    getProfile
));

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

