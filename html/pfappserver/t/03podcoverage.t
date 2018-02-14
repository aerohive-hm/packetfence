#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};

eval "use Test::Pod::Coverage 1.04";
plan skip_all => 'Test::Pod::Coverage 1.04 required' if $@;

eval "use Pod::Coverage 0.20";
plan skip_all => 'Pod::Coverage 0.20 required' if $@;

all_pod_coverage_ok();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

