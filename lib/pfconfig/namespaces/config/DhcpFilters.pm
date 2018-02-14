package pfconfig::namespaces::config::DhcpFilters;

=head1 NAME

pfconfig::namespaces::config::DhcpFilter

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::DhcpFilters

This module creates the configuration hash associated to dhcp_filters.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw(
    $dhcp_filters_config_file
);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $dhcp_filters_config_file;
    $self->{child_resources} = [ 'FilterEngine::DhcpScopes'];
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };

    $self->cleanup_whitespaces( \%tmp_cfg );

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

