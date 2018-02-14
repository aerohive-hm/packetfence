package pfconfig::namespaces::config::RadiusFilters;

=head1 NAME

pfconfig::namespaces::config::RadiusFilter

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::RadiusFilters

This module creates the configuration hash associated to radius_filters.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($radius_filters_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $radius_filters_config_file;
    $self->{child_resources} = [ 'FilterEngine::RadiusScopes'];
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

