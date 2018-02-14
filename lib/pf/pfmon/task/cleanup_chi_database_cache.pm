package pf::pfmon::task::cleanup_chi_database_cache;

=head1 NAME

pf::pfmon::task::cleanup_chi_database_cache - class for pfmon task cleanup chi database cache

=cut

=head1 DESCRIPTION

pf::pfmon::task::cleanup_chi_database_cache

=cut

use strict;
use warnings;
use pf::log;
use pf::dal::chi_cache;
use pf::error qw(is_error);
use Moose;
extends qw(pf::pfmon::task);

has 'batch' => ( is => 'rw', default => 1000 );
has 'timeout' => ( is => 'rw', default => 10 );


my $logger = get_logger();

=head2 run

run the cleanup chi database cache task

=cut

sub run {
    my ($self) = @_;
    my $batch = $self->batch;
    my $time_limit = $self->timeout;
    my $now        = pf::dal->now();
    my %search = (
        -where => {
            expires_at  => {
                "<=" => $now,
            },
        },
        -limit => $batch,
    );
    pf::dal::chi_cache->batch_remove(\%search, $time_limit);

    $logger->debug("Done expiring database CHI cache");
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
