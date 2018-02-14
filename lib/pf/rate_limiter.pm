package pf::rate_limiter;

=head1 NAME

pf::rate_limiter -

=cut

=head1 DESCRIPTION

pf::rate_limiter

=cut

use strict;
use warnings;
use pf::Redis;

our $LUA_INCR_RATE_LIMITER_SHA1;

our $LUA_INCR_RATE_LIMITER = <<LUA;
    local count = redis.call("incr", KEYS[1])
    if tonumber(count) == 1 then
        redis.call("expire", KEYS[1], ARGV[1])
    end
LUA

our $RATE_LIMITER_PREFIX = "RateLimiter:";

sub is_pass_limit {
    my ($key, $limit, $expire) = @_;
    my $rkey = $RATE_LIMITER_PREFIX . $key;
    my $redis = get_redis();
    my $count = $redis->get($rkey);
    if (defined $count && $count >= $limit) {
        return 1;
    }
    my $reply = $redis->evalsha($LUA_INCR_RATE_LIMITER_SHA1, 1, $rkey, $expire);
    return 0;
}

=head2 get_redis

get_redis

=cut

sub get_redis {
    pf::Redis->new(on_connect => \&on_connect);
}

=head2 on_connect

What actions to do when connecting to a redis server

=cut

sub on_connect {
    my ($redis) = @_;
    if($LUA_INCR_RATE_LIMITER_SHA1) {
        my ($loaded) = $redis->script('EXISTS',$LUA_INCR_RATE_LIMITER_SHA1);
        return if $loaded;
    }
    ($LUA_INCR_RATE_LIMITER_SHA1) = $redis->script('LOAD',$LUA_INCR_RATE_LIMITER);
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
