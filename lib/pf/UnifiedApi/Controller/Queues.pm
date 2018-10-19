package pf::UnifiedApi::Controller::Queues;

=head1 NAME

pf::UnifiedApi::Controller::Queues -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Queues

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::RestRoute';
use pf::pfqueue::stats;


sub stats {
    my ($self) = @_;
    my $stats = pf::pfqueue::stats->new;
    # build hashref
    my %queue = ();
    foreach my $item (@{ $stats->queue_counts }) {
        $queue{$item->{name}} = { count => $item->{count}, outstanding => [], expired => [] };
    }
    foreach my $item (@{ $stats->counters }) {
        push $queue{$item->{queue}}{outstanding}, { name => $item->{name}, count => $item->{count} };
    }
    foreach my $item (@{ $stats->miss_counters }) {
        push $queue{$item->{queue}}{expired}, { name => $item->{name}, count => $item->{count} };
    }
    #build json
    my $json = [];
    while( my( $key, $value ) = each %queue ){
        # rebuild hash,
        #   replace empty []'s w/ undef
        push $json, { queue => $key, stats => $value };
    }
    
    return $self->render(status => 200, json => { items => $json });
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
