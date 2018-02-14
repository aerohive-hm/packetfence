package pf::services::manager::httpd_admin;
=head1 NAME

pf::services::manager::httpd_admin add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_admin

=cut

use strict;
use warnings;
use Moo;
use List::MoreUtils qw(uniq);
use pf::config qw(
    @internal_nets
    @portal_ints
);
use pf::file_paths qw(
    $install_dir
);

extends 'pf::services::manager::httpd';

has '+name' => (default => sub { 'httpd.admin' } );

has '+shouldCheckup' => ( default => sub { 0 }  );

use pf::config qw(
    %Config
    $management_network
    $OS
);
use pf::cluster;

=head2 vhosts

The list of IP addresses on which the process should listen

=cut

sub vhosts {
    my ($self) = @_;
    my @vhosts;
    if ( $management_network && defined($management_network->{'Tip'}) && $management_network->{'Tip'} ne '') {
        if (defined($management_network->{'Tvip'}) && $management_network->{'Tvip'} ne '') {
            push @vhosts, $management_network->{'Tvip'};
        } elsif ( $cluster_enabled ){
            push @vhosts, pf::cluster::current_server->{management_ip};
            push @vhosts, $ConfigCluster{'CLUSTER'}{'management_ip'};
        } else {
            push @vhosts, $management_network->{'Tip'};
       }
    } else {
        push @vhosts, "0.0.0.0";
    }
    return \@vhosts;
}


=head2 additionalVars

=cut

sub additionalVars {
    my ($self) = @_;
    return (
        preview_ip   => $self->portal_preview_ip,
        graphite_url => "localhost:9000"
    );
}

=head2 portal_preview_ip

The creates the portal preview ip addresss

=cut

sub portal_preview_ip {
    my ($self) = @_;
    if (!$cluster_enabled) {
        return "127.0.0.1";
    }
    my  @ints = uniq (@internal_nets, @portal_ints);
    return $ints[0]->{Tvip} ? $ints[0]->{Tvip} : $ints[0]->{Tip};
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
