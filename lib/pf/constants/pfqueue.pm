package pf::constants::pfqueue;

=head1 NAME

pf::constants::pfqueue - constants for pfqueue service

=cut

=head1 DESCRIPTION

pf::constants::pfqueue

=cut

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
    $PFQUEUE_COUNTER
    $PFQUEUE_QUEUE_PREFIX
    $PFQUEUE_EXPIRED_COUNTER
    $PFQUEUE_WORKERS_DEFAULT
    $PFQUEUE_MAX_TASKS_DEFAULT
    $PFQUEUE_TASK_JITTER_DEFAULT
    $PFQUEUE_WEIGHT_DEFAULT
    $PFQUEUE_DELAYED_QUEUE_BATCH_DEFAULT
    $PFQUEUE_DELAYED_QUEUE_WORKERS_DEFAULT
    $PFQUEUE_DELAYED_QUEUE_SLEEP_DEFAULT
    $PFQUEUE_WEIGHTS
);

our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

our $PFQUEUE_COUNTER = "TaskCounters";

our $PFQUEUE_EXPIRED_COUNTER = "ExpiredCounters";

our $PFQUEUE_QUEUE_PREFIX = "Queue:";

our $PFQUEUE_WORKERS_DEFAULT = 0;

our $PFQUEUE_WEIGHT_DEFAULT = 1;

our $PFQUEUE_DELAYED_QUEUE_BATCH_DEFAULT = 100;

our $PFQUEUE_DELAYED_QUEUE_WORKERS_DEFAULT = 1;

our $PFQUEUE_DELAYED_QUEUE_SLEEP_DEFAULT = 100;

our $PFQUEUE_MAX_TASKS_DEFAULT = 2000;

our $PFQUEUE_TASK_JITTER_DEFAULT = 100;

our $PFQUEUE_WEIGHTS = 'QueueWeights';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
