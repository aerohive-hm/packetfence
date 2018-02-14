package pfconfig::namespaces::config::SwitchFilters;

=head1 NAME

pfconfig::namespaces::config::template

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::template

This module creates the configuration hash associated to somefile.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw(
    $switch_filters_config_file
);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $switch_filters_config_file;
    $self->{child_resources} = [ 'FilterEngine::SwitchScopes'];

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
