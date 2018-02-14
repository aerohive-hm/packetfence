#!/usr/bin/perl
=head1 NAME

nodecategory.t

=head1 DESCRIPTION

pf::nodecategory module testing

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 4;
use Test::NoWarnings;
use Test::Exception;
use File::Basename qw(basename);

Log::Log4perl->init("log.conf");
my $logger = Log::Log4perl->get_logger( basename($0) );
Log::Log4perl::MDC->put( 'proc', basename($0) );
Log::Log4perl::MDC->put( 'tid',  0 );

BEGIN { use_ok('pf::nodecategory') }

# subs
can_ok('pf::nodecategory', qw(
    nodecategory_db_prepare
    nodecategory_view_all
    nodecategory_view
    nodecategory_view_by_name
    nodecategory_add
    nodecategory_modify
    nodecategory_exist
    nodecategory_lookup
));

throws_ok { nodecategory_add((notes => 'no-name')) } # passing an anonymous hash, forgetting the mandatory 'name'
    qr/name missing/,
    'nodecategory_add without a name parameter';


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

