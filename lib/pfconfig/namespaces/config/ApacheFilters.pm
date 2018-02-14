package pfconfig::namespaces::config::ApacheFilters;

=head1 NAME

pfconfig::namespaces::config::ApacheFilters

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::ApacheFilters

This module creates the configuration hash associated to apache_filters.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($apache_filters_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $apache_filters_config_file;
}

sub build_child {
    my ($self) = @_;

    $self->cleanup_whitespaces( $self->{cfg} );

    return $self->{cfg};
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

