package pfconfig::namespaces::config::AdminRoles;

=head1 NAME

pfconfig::namespaces::config::AdminRoles

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Switch

This module creates the configuration hash associated to admin_roles.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use Config::IniFiles;
use pf::file_paths qw($admin_roles_config_file);
use pf::constants::admin_roles;

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $admin_roles_config_file;
}

sub build_child {
    my ($self) = @_;

    my %ADMIN_ROLES = %{ $self->{cfg} };

    $self->cleanup_whitespaces( \%ADMIN_ROLES );
    foreach my $data ( values %ADMIN_ROLES ) {
        my $actions = $data->{actions} || '';
        my %action_data = map { $_ => undef } split /\s*,\s*/, $actions;
        $data->{ACTIONS} = \%action_data;
    }
    $ADMIN_ROLES{NONE}{ACTIONS} = {};
    $ADMIN_ROLES{ALL}{ACTIONS} = { map { $_ => undef } @pf::constants::admin_roles::ADMIN_ACTIONS };
    $ADMIN_ROLES{ALL_PF_ONLY}{ACTIONS} = { map { $_ => undef } grep {$_ !~ /^SWITCH_LOGIN_/} @pf::constants::admin_roles::ADMIN_ACTIONS };

    foreach my $key ( keys %ADMIN_ROLES ) {
        $self->cleanup_after_read( $key, $ADMIN_ROLES{$key} );
    }

    return \%ADMIN_ROLES;

}

sub cleanup_after_read {
    my ( $self, $id, $item ) = @_;

    # Seems we don't need to do it for the HASH, but I'll leave it here
    # just in case. Remove this when confirmed everything works fine
    #    $self->expand_list($item, qw(actions allowed_roles allowed_access_levels));
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

