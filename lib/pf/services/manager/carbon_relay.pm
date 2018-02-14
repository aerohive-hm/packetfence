package pf::services::manager::carbon_relay;

=head1 NAME

pf::services::manager::carbon_relay

=cut

=head1 DESCRIPTION

pf::services::manager::carbon_relay
carbon-relay daemon manager module for PacketFence.

=cut

use strict;
use warnings;
use pf::file_paths qw($install_dir);
use Moo;

extends 'pf::services::manager';

has '+name' => ( default => sub {'carbon-relay'} );
has '+optional' => ( default => sub {1} );

sub _cmdLine {
    my $self = shift;
    $self->executable
        . " --pidfile=" . $self->pidFile
        . " --config=$install_dir/var/conf/carbon.conf  --logdir=$install_dir/logs --nodaemon start";
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
