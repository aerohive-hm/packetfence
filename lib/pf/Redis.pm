package pf::Redis;

=head1 NAME

pf::Redis - A cache for redis client object

=cut

=head1 DESCRIPTION

pf::Redis

=cut

use strict;
use warnings;

use Redis::Fast;
use CHI;
use Log::Any::Adapter;
Log::Any::Adapter->set('Log4perl');
use POSIX::AtFork;

our $CHI_CACHE = CHI->new(driver => 'RawMemory', datastore => {});

=head2 new

Will create a Redis::Fast connection or a shared one

=cut

sub new {
    my ($self, %args) = @_;
    my $on_connect = delete $args{on_connect};
    my $redis = $CHI_CACHE->compute(\%args, { expire_if => \&expire_if }, sub { return compute_redis(\%args) });
    if ($redis && $on_connect) {
        $on_connect->($redis);
    }
    return $redis;
}

=head2 expire_if

Test to see of the redis connection is still alive

=cut

sub expire_if {
    my ($object, $cache) = @_;
    my $redis = $object->value;
    return !$redis->ping;
}

=head2 CLONE

Will clear out the redis cache

=cut

sub CLONE {
    $CHI_CACHE->clear;
}

POSIX::AtFork->add_to_child(\&CLONE);

=head2 compute_redis

Function to create the redis connection

=cut

sub compute_redis {
    my ($args) = @_;
    my $redis = Redis::Fast->new(%$args);
    return $redis;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
