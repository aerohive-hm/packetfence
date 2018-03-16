#!/usr/bin/perl

=head1 NAME

Nodes

=cut

=head1 DESCRIPTION

unit test for Nodes

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';
use Date::Parse;
use pf::dal::node;
use pf::dal::locationlog;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;

}

#insert known data
#run tests
use Test::More tests => 3;
use Test::Mojo;
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

$t->get_ok('/api/v1/nodes')
  ->status_is(200);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
