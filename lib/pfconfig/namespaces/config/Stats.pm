package pfconfig::namespaces::config::Stats;

=head1 NAME

pfconfig::namespaces::config::Stats

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Stats

This module creates the configuration hash associated to stats.conf

=cut


use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::log;
use pf::file_paths qw($stats_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $stats_config_file;
    
    $self->{listen_ints} = $self->{cache}->get_cache('interfaces::listen_ints');
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{$self->{cfg}};

    foreach my $key ( keys %tmp_cfg){
        $self->cleanup_whitespaces( \%tmp_cfg );
    }

    foreach my $int (@{$self->{listen_ints}}) {
        $tmp_cfg{"metric 'total dhcp leases remaining on $int' past day"} = {
            'type' => 'api',
            'statsd_type' => 'gauge',
            'statsd_ns' => 'source.packetfence.dhcp_leases_'.$int.'_day',
            'api_method' => 'GET',
            'api_path' => "/api/v1/dhcp/stats/$int",
            'api_compile' => '$[0].free',
            'interval' => '24s',
        };
        $tmp_cfg{"metric 'total dhcp leases remaining on $int' past week"} = {
            'type' => 'api',
            'statsd_type' => 'gauge',
            'statsd_ns' => 'source.packetfence.dhcp_leases_'.$int.'_week',
            'api_method' => 'GET',
            'api_path' => "/api/v1/dhcp/stats/$int",
            'api_compile' => '$[0].free',
            'interval' => '168s',
        };
        $tmp_cfg{"metric 'total dhcp leases remaining on $int' past month"} = {
            'type' => 'api',
            'statsd_type' => 'gauge',
            'statsd_ns' => 'source.packetfence.dhcp_leases_'.$int.'_month',
            'api_method' => 'GET',
            'api_path' => "/api/v1/dhcp/stats/$int",
            'api_compile' => '$[0].free',
            'interval' => '720s',
        };
        $tmp_cfg{"metric 'total dhcp leases remaining on $int' past year"} = {
            'type' => 'api',
            'statsd_type' => 'gauge',
            'statsd_ns' => 'source.packetfence.dhcp_leases_'.$int.'_year',
            'api_method' => 'GET',
            'api_path' => "/api/v1/dhcp/stats/$int",
            'api_compile' => '$[0].free',
            'interval' => '8760s',
        };
    }

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

