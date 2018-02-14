package pf::services::manager::radiusd;

=head1 NAME

pf::services::manager::radiusd add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::radiusd

=cut

use strict;
use warnings;

use List::MoreUtils qw(any);
use Moo;

use pf::authentication;
use pf::cluster;
use pf::file_paths qw(
    $var_dir
    $conf_dir
    $install_dir
);
use pf::services::manager::radiusd_child;
use pf::SwitchFactory;
use pf::util;

use pfconfig::cached_array;

extends 'pf::services::manager::submanager';

tie my @cli_switches, 'pfconfig::cached_array', 'resource::cli_switches';

has radiusdManagers => (is => 'rw', builder => 1, lazy => 1);

has '+name' => ( default => sub { 'radiusd' } );


sub _build_radiusdManagers {
    my ($self) = @_;

    my $listens = {};
    if ($cluster_enabled) {
        my $cluster_ip = pf::cluster::management_cluster_ip();
        $listens->{load_balancer} = {};
    }
    $listens->{auth} = {};
    $listens->{acct} = {};

    # 'Eduroam' RADIUS instance manager
    if ( @{ pf::authentication::getAuthenticationSourcesByType('Eduroam') } ) {
        $listens->{eduroam} = {};
    }

    if ( @cli_switches > 0 ) {
        $listens->{cli} = {};
    }

    my @managers = map {
        my $id       = $_;
        my $launcher = $self->launcher;
        my $name     = untaint_chain( $self->name . "-" . $id );

        pf::services::manager::radiusd_child->new(
            {   name         => $name,
                forceManaged => $self->isManaged,
                options      => $id,
            }
            )
    } keys %$listens;

    return \@managers;
}


sub managers {
    my ($self) = @_;
    return @{$self->radiusdManagers};
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

