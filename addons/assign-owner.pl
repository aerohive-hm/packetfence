#!/usr/bin/perl

=head1 NAME

assign-owner.pl

=head1 SYNOPSIS

./assign-owner.pl <MAC address> <pid>

=head1 DESCRIPTION

Assign an owner to a node by its MAC address.
Will create the MAC address if it doesn't already exist.
Will create the owner if it doesn't already exist.

=cut


use strict;
use warnings;

use lib '/usr/local/pf/lib';

use Pod::Usage;
use pf::util;
use pf::log;
use pf::node;
use pf::person;

use Data::Dumper;
get_logger->info(Dumper(@ARGV));

my $mac = clean_mac($ARGV[0]);
my $owner = $ARGV[1];

if(!$mac) {
    print STDERR "Missing or invalid MAC address\n";
    pod2usage(1);
}

if(!$owner) {
    print STDERR "Missing owner\n";
    pod2usage(1);
}

if(!person_exist($owner)) {
    person_add($owner);
}

node_modify($mac, pid => $owner);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

