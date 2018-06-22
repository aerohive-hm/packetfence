package pf::services::manager::etcd;
=head1 NAME

pf::services::manager::etcd

=cut

=head1 DESCRIPTION

pf::services::manager::etcd

=cut

use strict;
use warnings;
use Moo;
use pf::config qw(
    %Config
    $management_network
);
use pf::cluster qw(
    @cluster_servers
);

use pf::file_paths qw(
    $generated_conf_dir
    $install_dir
    $conf_dir
    $var_dir
);

use pf::log;
use pf::util;

use Template;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'etcd' } );

sub isManaged {
    my ($self) = @_;
    return  isenabled($Config{'services'}{'pfdhcp'}) && $self->SUPER::isManaged();
}

sub generateConfig {
    my ($self,$quick) = @_;
    my $logger = get_logger();
    my ($package, $filename, $line) = caller();

    my %tags;
    $tags{'template'} = "$conf_dir/etcd.conf.yml";
    $tags{'initial_cluster'} = '';
    $tags{'data_dir'} = $var_dir.'/etcd';
    $tags{'listen_peer_urls'} = "http://$management_network->{'Tip'}:2380";
    $tags{'initial_advertise_peer_urls'} = "http://$management_network->{'Tip'}:2380";
    $tags{'listen_client_urls'} = "http://$management_network->{'Tip'}:2379,http://127.0.0.1:2379";
    $tags{'advertise_client_urls'} = "http://$management_network->{'Tip'}:2379";
    $tags{'initial_cluster_token'} = "etcd-cluster";
    $tags{'etcd_name'} = "Miguel";

    my $i = 0;
    foreach my $member (pf::cluster::enabled_servers) {
        $tags{'initial_cluster'} .= "infra$i=http://$member->{management_ip}:2380,";
        if ($member->{management_ip} eq $management_network->{'Tip'}) {
            $tags{'etcd_name'} = "infra$i";
        }
        $i++;
    }
    my $tt = Template->new(ABSOLUTE => 1);
    $tt->process("$conf_dir/etcd.conf.yml", \%tags, "$generated_conf_dir/etcd.conf.yml") or die $tt->error();

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
