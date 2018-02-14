package pf::StatsD::Timer;

=head1 NAME

pf::StatsD::Timer -

=cut

=head1 DESCRIPTION

pf::StatsD::Timer

Is a scoped statsd timer

=head1 SYNOPSIS

Simple usage example

    sub function {
        my $timer = pf::StatsD::Timer->new;
        ...
        # Will send stats for function when $timer goes out of scope
    }

How to use multiple timers with the same function

    sub function {
        my $timer = pf::StatsD::Timer->new;
        ...
        my $result = do {
            my $timer2 = pf::StatsD::Timer->new({'stat' => 'nameofstat.timing'});
            # $timer2 will go our of scope at the end of the do block
            # the do black will return the results of other_function();
            other_function();
        };
        ...
        # Will send stats for function when $timer goes out of scope
    }


How to use time different parts of a function

    sub function {
        my $timer = pf::StatsD::Timer->new;
        ... # Send stats in t
        $timer->send_timing("work");
        ...
        # Will send stats for function when $timer goes out of scope
    }

=cut

use strict;
use warnings;
use pf::StatsD;
use Time::HiRes;
use pfconfig::cached_hash;

tie our %levels, 'pfconfig::cached_hash', 'resource::stats_levels';

=head2 $timer = $self->new({ 'stat' => "stat", sample_rate => $sample_rate });

=cut

sub new {
    my ($proto, $args) = @_;
    my $class = ref($proto) || $proto;
    $args //= {};
    $args->{start_time} //= Time::HiRes::gettimeofday;
    $args->{sample_rate} //= 0.10;
    $args->{level} //= 5;
    #Get the name of the function enclosing this call
    $args->{'stat'} //= (caller(1))[3];
    my $self  = {%$args};
    return bless $self, $class;
}

sub send_timing {
    my ($self, $sub_stat) = @_;
    if($self->{level} <= $levels{timing}){
        $pf::StatsD::statsd->end($self->{'stat'} . ".$sub_stat" . ".timing", $self->{'start_time'}, $self->{'sample_rate'});
    }
}

=head2 DESTROY

=cut

sub DESTROY {
    my ($self) = @_;
    if($self->{level} <= $levels{timing}){
        $pf::StatsD::statsd->end($self->{'stat'} . ".timing" , $self->{'start_time'}, $self->{'sample_rate'});
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

