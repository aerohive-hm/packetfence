package pfappserver::PacketFence::Controller::Pfqueue;

=head1 NAME

pfappserver::PacketFence::Controller::Pfqueue - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use Readonly;
use URI::Escape::XS qw(uri_escape uri_unescape);
use namespace::autoclean;
use pf::cluster;

BEGIN { extends 'pfappserver::Base::Controller'; }

=head2 index

=cut

sub index :Path : Args(0) {
    my ($self, $c) = @_;
    my $model = $c->model('Pfqueue');
    $c->stash({
        stats => $model->stats,
    });
    $c->forward('graphs');
}

=head2 graphs

Generate the graphs for the queue page

=cut

sub graphs :Private {
    my ($self, $c, $start, $end) = @_;
    my $width = $c->request->param('width');

    my $graph = {
                'description' => $c->loc('Last hour queue counts'),
                'target' => 'aliasByNode(stats.gauges.*.pfqueue.stats.queue_counts.*,6)',
                'columns' => 2
               };

    $graph->{url} = $c->forward(Graph => '_buildGraphiteURL', ['-1h', "", $graph]);

    $c->stash->{queue_counts_graph} = $graph;
}

sub counters :Args {
    my ($self, $c) = @_;
    my $model = $c->model('Pfqueue');
    my $counters = [ map { $_->{count} > 0 } @{$model->counters} ];
    $c->stash({
        current_view => 'JSON',
        counters => $counters,
        miss_counters => $model->miss_counters,
    });
}

sub cluster :Local : Args(0) {
    my ($self, $c) = @_;
    $c->stash({
        servers => pf::cluster::queue_stats(),
    });
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
