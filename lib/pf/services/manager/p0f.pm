package pf::services::manager::p0f;

=head1 NAME

pf::services::manager::p0f management module.

=cut

=head1 DESCRIPTION

pf::services::manager::p0f

=cut

use strict;
use warnings;
use Moo;
use fingerbank::Config;
use pf::config qw(@ha_ints @internal_nets $management_network);
use List::MoreUtils qw(uniq);
use Algorithm::Combinatorics qw(combinations_with_repetition);
use pf::cluster;
use pf::log;

extends 'pf::services::manager';

has '+name' => ( default => sub {'p0f'} );
has '+optional' => ( default => sub {1} );

sub _cmdLine {
    my ($self) = @_;
    my $FingerbankConfig = fingerbank::Config::get_config;
    my $p0f_map = $FingerbankConfig->{tcp_fingerprinting}{p0f_map_path};
    my $p0f_sock = $FingerbankConfig->{tcp_fingerprinting}{p0f_socket_path};
    my $pid_file = $self->pidFile;
    my $name = $self->name;
    my $p0f_cmdline;
    if ($cluster_enabled) {
        my $p0f_bpf_filter = bpf_filter();
        $p0f_cmdline= $self->executable . " -i any -p -f $p0f_map -s $p0f_sock" . " '$p0f_bpf_filter' ";
    } else {
        $p0f_cmdline= $self->executable . " -i any -p -f $p0f_map -s $p0f_sock" . " 'not ( (net 127) or (host 0:0:0:0:0:0:0:1) )' ";
    }
    return $p0f_cmdline;
}

sub bpf_filter {
    my  @ints = uniq (@internal_nets, $management_network);
    my $filter = 'not ( ( ';
    foreach my $int (@ints) {
        my $interface = $int->{Tint};
        my $ip = pf::cluster::members_ips($interface);
        my @array = uniq (map { $ip->{$_} } keys %$ip);
        push(@array, pf::cluster::cluster_ip($interface));
        my $iter = combinations_with_repetition(\@array,2);
        while (my $combination = $iter->next) {
            my @tmp_bpf_filter = map { "host $_"} @$combination;
            my $p0f_bpf_filter = join(" and ", @tmp_bpf_filter);
            $filter .= $p0f_bpf_filter;
            $filter .= ') or ( ';
        }
    }
    $filter .= 'net 127) or (host 0:0:0:0:0:0:0:1) )';
    return $filter;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
