#!/usr/bin/perl

=head1 NAME

import

=cut

=head1 DESCRIPTION

unit test for import

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

use Test::More tests => 3;

#This test will running last
use Test::NoWarnings;
use pf::import;
use File::Temp;

my $fh = File::Temp->new;

my $name = $fh->filename;

system("perl -T -I/usr/local/pf/t  -Msetup_test_config /usr/local/pf/bin/pfcmd.pl import nodes $name");

is($?, 0, "Succeeded running with an empty file");

for my $o (0..255) {
    print $fh sprintf("00:11:55:22:33:%02x,default\n", $o);
}

$fh->flush;

system("/usr/local/pf/bin/pfcmd import nodes $name columns=mac,pid");

is($?, 0, "Succeeded importing 00:11:55:22:33:00 - 00:11:55:22:33:ff with the default user");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

