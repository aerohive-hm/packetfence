#!/usr/bin/perl

=head1 NAME

CHI

=cut

=head1 DESCRIPTION

unit test for pf::CHI

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


use Test::More tests => 10;
use Test::Exception;

#This test will running last
use Test::NoWarnings;
use_ok("pf::CHI");

my $cache_miss = 0;

my $cache = pf::CHI->new( namespace => 't');
$cache->clear;

# Test computing with undef values

my $result = $cache->compute_with_undef('undef_value', sub { $cache_miss++ ; undef });

is(undef, $result,
    "Computing undef returns undef in a cache miss");

is(1, $cache_miss,
    "Computing an uncomputed undef value increments the hits");

$result = $cache->compute_with_undef('undef_value', sub { $cache_miss++ ; undef });

is(undef, $result,
    "Computing undef returns undef in a cache hit");

is(1, $cache_miss,
    "Computing a computed undef value does not increment the hits");

# Test computing with non-undef values

$cache_miss = 0;
$result = $cache->compute_with_undef('defined_value', sub { $cache_miss++ ; "turkey" });

is("turkey", $result,
    "Computing a defined value returns the value in a cache miss");

is(1, $cache_miss,
    "Computing an uncomputed defined value increments the hits");

$result = $cache->compute_with_undef('defined_value', sub { $cache_miss++ ; "turkey" });

is("turkey", $result,
    "Computing a defined value returns the value in a cache hit");

is(1, $cache_miss,
    "Computing a computed defined value does not increment the hits");
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

