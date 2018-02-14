package pfconfig::namespaces::config::Cluster;

=head1 NAME

pfconfig::namespaces::config::Cluster

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Cluster

This module creates the configuration hash associated to cluster.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($cluster_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $cluster_config_file;
    $self->{child_resources} = ['config::Pf', 'resource::cluster_servers', 'resource::cluster_hosts', 'resource::network_config'];
}

sub build_child {
    my ($self) = @_;

    my %cfg = %{$self->{cfg}};
    $self->cleanup_whitespaces(\%cfg);
    my @servers;
    my %tmp_cfg;

    foreach my $section (@{$self->{ordered_sections}}){
        # we don't want groups
        next if ($section =~ m/\s/i);

        my $server = $cfg{$section};

        foreach my $group ($self->GroupMembers($section)){
            $group =~ s/^$section //g;
            $server->{$group} = $cfg{"$section $group"};
        }

        $tmp_cfg{$section} = $server;

        $server->{host} = $section;
        # we add it to the servers list if it's not the shared CLUSTER config
        if ($section eq "CLUSTER") {
            $self->{_CLUSTER} = $server;
        }
        else {
            push @servers, $server;
        }
    }

    $self->{_servers} = \@servers;

    return \%tmp_cfg;

}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

