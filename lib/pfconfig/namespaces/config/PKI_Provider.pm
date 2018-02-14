package pfconfig::namespaces::config::PKI_Provider;

=head1 NAME

pfconfig::namespaces::config::PKI_Provider

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::PKI_Provider

This module creates the configuration hash associated to pki_provider.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($pki_provider_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $pki_provider_config_file;
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

