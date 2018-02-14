package pf::pfmon::task::auth_log_cleanup;

=head1 NAME

pf::pfmon::task::auth_log_cleanup - class for pfmon task auth log cleanup

=cut

=head1 DESCRIPTION

pf::pfmon::task::auth_log_cleanup

=cut

use strict;
use warnings;
use Moose;
use pf::auth_log;
extends qw(pf::pfmon::task);

has 'batch' => ( is => 'rw');
has 'timeout' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );
has 'window' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );

=head2 run

run the auth log cleanup task

=cut

sub run {
    my ($self) = @_;
    my $window = $self->window;
    pf::auth_log::cleanup($window, $self->batch, $self->timeout) if $self->window;
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
