package pf::pfmon::task::queue_stats;

=head1 NAME

pf::pfmon::task::queue_stats - class for pfmon task queue counts

=cut

=head1 DESCRIPTION

pf::pfmon::task::queue_stats

=cut

use strict;
use warnings;
use pf::log;
use pf::StatsD;
use pf::pfqueue::stats;
use Moose;
extends qw(pf::pfmon::task);


=head2 run

Poll the queue counts and record them in statsd

=cut

sub run {
    my ($self) = @_;
    my $logger = get_logger;
    $logger->debug("Polling counters from queues to record them in statsd");
    my $statsd = pf::StatsD->new;

    my $queue_counts = pf::pfqueue::stats->new->queue_counts;
    for my $info (@{$queue_counts}) {
        my $queue_name = $info->{name};
        my $count = $info->{count};
        $logger->debug("Setting queue count of $queue_name to $count in statsd");
        $statsd->gauge("pfqueue.stats.queue_counts.$queue_name", $count, 1);
    }
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
