package pf::pfmon::task::radius_audit_log_cleanup;

=head1 NAME

pf::pfmon::task::radius_audit_log_cleanup - class for pfmon task radius audit log cleanup

=cut

=head1 DESCRIPTION

pf::pfmon::task::radius_audit_log_cleanup

=cut

use strict;
use warnings;
use Moose;
use pf::radius_audit_log;
extends qw(pf::pfmon::task);

has 'batch' => ( is => 'rw');
has 'window' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );
has 'timeout' => ( is => 'rw', isa => 'PfInterval', coerce => 1 );

=head2 run

run the radius audit log cleanup task

=cut

sub run {
    my ($self) = @_;
    my $window = $self->window;
    radius_audit_log_cleanup($window, $self->batch, $self->timeout) if $window;
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
