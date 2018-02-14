#!/usr/bin/perl

=head1 NAME

node - 

=cut

=head1 DESCRIPTION

node

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::node;
use pf::SwitchFactory;
use pf::Connection::ProfileFactory;
use Data::Dumper;
use Benchmark qw(timethis cmpthese);
use CHI::Memoize qw(unmemoize);

my $mac = "00:00:00:00:00:ff";
bench_node_view();
bench_node_exist();
bench_switch_factory();
bench_profile_factory();

sub bench_node_view {
    bench_cache("pf::node::_node_view", sub { my $node = pf::node::node_view($mac) });
}

sub bench_node_exist {
    bench_cache("pf::node::_node_exist", sub { my $node = pf::node::node_exist($mac) });
}

sub bench_switch_factory {
    bench_cache("pf::SwitchFactory::instantiate", sub { my $switch = pf::SwitchFactory->instantiate("192.168.0.1")});
}

sub bench_profile_factory {
    bench_cache("pf::Connection::ProfileFactory::instantiate", sub { my $switch = pf::Portal::ProfileFactory->instantiate($mac)});
}

sub bench_cache {
    my ($func_id, $func, $count) = @_;
    print "\n$func_id\n";
    my %counts;
    $count //= 0;
    $counts{"with caching"} = timethis($count, $func, "with caching");

    unmemoize($func_id);

    $counts{"without caching"} = timethis($count, $func, "without caching");
    cmpthese(\%counts);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

