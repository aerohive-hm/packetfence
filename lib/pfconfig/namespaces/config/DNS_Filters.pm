package pfconfig::namespaces::config::DNS_Filters;

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
use pf::file_paths qw($dns_filters_config_file $dns_filters_default_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $dns_filters_config_file;
    $self->{child_resources} = [ 'FilterEngine::DNS_Scopes'];
    my $defaults = Config::IniFiles->new( -file => $dns_filters_default_config_file);
    $self->{added_params}->{'-import'} = $defaults;
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
