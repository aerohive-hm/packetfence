package pf::pfmon::task::locationlog_cleanup;

=head1 NAME

pf::pfmon::task::locationlog_cleanup - class for pfmon task locationlog cleanup

=cut

=head1 DESCRIPTION

pf::pfmon::task::locationlog_cleanup

=cut

use strict;
use warnings;
use Moose;
use pf::locationlog;
extends qw(pf::pfmon::task);

has 'batch' => ( is => 'rw' );
has 'window' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );
has 'timeout' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );

=head2 run

run the locationlog cleanup task

=cut

sub run {
    my ($self) = @_;
    my $window = $self->window;
    locationlog_cleanup($window, $self->batch, $self->timeout) if $self->window;
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
