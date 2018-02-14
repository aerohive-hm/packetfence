#!/usr/bin/perl
=head1 NAME

tieconfig.pl

=head1 DESCRIPTION

Some performance benchmarks on tied config files accessing

=cut

use strict;
use warnings;
use diagnostics;

use Benchmark qw(cmpthese);

use lib '/usr/local/pf/lib';

=head1 TESTS

=cut

use pf::config;

our $trapsLimitThreshold = $Config{'snmp_traps'}{'trap_limit_threshold'};

sub accessTied {
    return $Config{'snmp_traps'}{'trap_limit_threshold'} + 1;
}

sub accessGlobal {
    return $trapsLimitThreshold + 1;
}

cmpthese(1000, {
    accessTied => sub { 
        accessTied();
    },
    accessGlobal => sub { 
        accessGlobal();
    }
});

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut
