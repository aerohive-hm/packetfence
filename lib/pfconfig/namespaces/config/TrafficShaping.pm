package pfconfig::namespaces::config::TrafficShaping;

=head1 NAME

pfconfig::namespaces::config::TrafficShaping

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::TrafficShaping

This module creates the configuration hash associated to traffic_shaping.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($traffic_shaping_config_file);
use pf::util;

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $traffic_shaping_config_file;
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };

    $self->cleanup_whitespaces( \%tmp_cfg );
    for my $data (values %tmp_cfg) {
        for my $c (qw(upload download)) {
            $data->{$c} = unpretty_bandwidth($data->{$c});
        }
    }

    return \%tmp_cfg;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
