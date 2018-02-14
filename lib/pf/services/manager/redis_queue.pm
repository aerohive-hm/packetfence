package pf::services::manager::redis_queue;

=head1 NAME

pf::services::manager::redis_queue - Service manager for the redis queue

=cut

=head1 DESCRIPTION

pf::services::manager::redis_queue

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw(
    $install_dir
    $generated_conf_dir
);

extends 'pf::services::manager::redis';

=head2 name

The name of the redis service

=cut

has '+name' => (default => sub { 'redis_queue' } );

sub _cmdLine {
    my $self = shift;
    $self->executable . " $generated_conf_dir/" . $self->name . ".conf" . " --daemonize no";
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
