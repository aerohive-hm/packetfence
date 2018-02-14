#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};
eval "use Test::Pod 1.14";
plan skip_all => 'Test::Pod 1.14 required' if $@;

all_pod_files_ok();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

