package pfconfig::namespaces::config::Roles;

=head1 NAME

pfconfig::namespaces::config::Roles

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Roles

This module creates the configuration hash associated to roles.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw(
    $roles_default_config_file
    $roles_config_file
);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file}              = $roles_config_file;

    my $defaults = Config::IniFiles->new( -file => $roles_default_config_file );
    $self->{added_params}->{'-import'} = $defaults;
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };

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

