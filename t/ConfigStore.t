#!/usr/bin/perl
=head1 NAME

ConfigStore add documentation

=cut

=head1 DESCRIPTION

ConfigStore

=cut

use strict;
use warnings;

use File::Slurp qw(read_dir);
use Test::Harness;
use File::Spec::Functions;
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

runtests(
    map { $_=catfile('ConfigStore',$_) }
    grep { /\.t$/ }
    read_dir ('ConfigStore')
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
