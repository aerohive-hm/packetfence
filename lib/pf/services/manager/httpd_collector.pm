package pf::services::manager::httpd_collector;

=head1 NAME

pf::services::manager::httpd_collector

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_collector

=cut

use strict;
use warnings;
use Moo;

use pf::config qw(
    $management_network
    %Config
    $OS
);
use pf::cluster;
use List::MoreUtils qw(uniq);
use pf::file_paths qw(
    $install_dir
);

extends 'pf::services::manager::httpd';

has '+name' => (default => sub { 'httpd.collector' } );


sub vhosts {
    my ($self) = @_;
    my @vhosts;
    if ($management_network && defined($management_network->{'Tip'}) && $management_network->{'Tip'} ne '') {
        if (defined($management_network->{'Tvip'}) && $management_network->{'Tvip'} ne '') {
            push @vhosts, $management_network->{'Tvip'};
        }
        else {
            push @vhosts, $management_network->{'Tip'};
        }
        push @vhosts, $ConfigCluster{'CLUSTER'}{'management_ip'} if ($cluster_enabled);
    }

    return [uniq @vhosts];
}

sub port {
    return $Config{ports}{collector};
}

sub additionalVars {
    my ($self) = @_;
    my %vars = (
        vhosts => $self->vhosts,
    );

    return %vars;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
