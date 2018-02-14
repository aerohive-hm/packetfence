#!/usr/bin/perl -w

package pf;
use strict;
use warnings;
use Module::Pluggable
  search_path => 'pf',
  except      => [qw(pf::WebAPI)],
  inner       => 0,
  sub_name    => 'modules';

=head1 NAME

has_test

=cut

=head1 DESCRIPTION

has_test

=cut

package main;
use strict;
use warnings;
use diagnostics;
use File::Spec::Functions;
# pf core libs
use lib '/usr/local/pf/lib';
use Test::More;

for my $module ( pf->modules ) {
    my $test = "${module}.t";
    my @parts = split(/::/,$test);
    shift @parts;
    $test = join('/',@parts);
    my $file = catfile('/usr/local/pf/t/unittest',@parts);
    ok -e $file,"$module has a test $file";
}

done_testing();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


