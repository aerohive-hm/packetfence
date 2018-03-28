#!/usr/bin/perl

=head1 NAME

I18N

=cut

=head1 DESCRIPTION

unit test for I18N

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 9;
use Test::Mojo;

#This test will running last
use Test::NoWarnings;

my $t = Test::Mojo->new('pf::UnifiedApi');

$t->get_ok('/api/v1/translations')
  ->status_is(200)
  ->json_has('/items')
  ;

$t->get_ok('/api/v1/translation/en')
  ->status_is(200)
  ->json_has('/item')
  ->json_is('/item/lang', 'en')
  ->json_has('/item/lexicon')
  ;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

