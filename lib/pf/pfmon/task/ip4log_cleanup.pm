package pf::pfmon::task::ip4log_cleanup;

=head1 NAME

pf::pfmon::task::ip4log_cleanup - class for pfmon task ip4log cleanup

=cut

=head1 DESCRIPTION

pf::pfmon::task::ip4log_cleanup

=cut

use strict;
use warnings;
use Moose;
use pf::ip4log;
use pf::util qw(isenabled);
extends qw(pf::pfmon::task);

has 'batch' => ( is => 'rw', default => "100" );
has 'timeout' => ( is => 'rw', default => "10s" );
has 'window' => ( is => 'rw', default => "1M" );

has 'rotate' => ( is => 'rw');
has 'rotate_batch' => ( is => 'rw', default => "100" );
has 'rotate_timeout' => ( is => 'rw', default => "10s" );
has 'rotate_window' => ( is => 'rw', default => "1W" );

=head2 run

run the ip4log cleanup task

=cut

sub run {
    my ($self) = @_;
    if (isenabled($self->rotate)) {
        my $rotate_window = $self->rotate_window;
        if ($rotate_window) {
            pf::ip4log::rotate($rotate_window, $self->rotate_batch, $self->rotate_timeout);
        }
        my $window = $self->window;
        if ($window) {
            pf::ip4log::cleanup_archive($window, $self->batch, $self->timeout);
        }
    }
    else {
        my $window = $self->window;
        if ($window) {
            pf::ip4log::cleanup_history($window, $self->batch, $self->timeout);
        }
    }
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
