#!/usr/bin/perl

=head1 NAME

radius-hook.pl - taps directly into pf::radius for profiling / debugging

=cut

use strict;
use warnings;
use Data::Dumper;

use constant INSTALL_DIR => '/usr/local/pf';
use lib INSTALL_DIR . "/lib";

use pf::radius::custom;

# perl -d:SmallProf variables 
%DB::packages = ( 'main' => 1, 'pf::radius' => 1, 'pf::SwitchFactory' => 1); 
$DB::drop_zeros = 1;

my $radius = new pf::radius::custom();
# unregistered
#print Dumper($radius->authorize(
#    "Wireless-802.11", "192.168.1.60", 0, "aa:bb:cc:dd:ee:ff", 12345, "aabbccddeeff", "Inverse-Invite")
#);

# registered
print Dumper($radius->authorize(
    "Wireless-802.11", "192.168.1.60", 0, "00:13:ce:58:42:e2", 12345, "aabbccddeeff", "Inverse-Invite")
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut
