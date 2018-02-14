package pfconfig::namespaces::config::Realm;

=head1 NAME

pfconfig::namespaces::config::Realm

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Realm

This module creates the configuration hash associated to realm.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw(
    $realm_default_config_file
    $realm_config_file
);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file}              = $realm_config_file;
    $self->{expandable_params} = qw(categories);

    my $defaults = Config::IniFiles->new( -file => $realm_default_config_file );
    $self->{added_params}->{'-import'} = $defaults;
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };

    foreach my $key ( keys %tmp_cfg ) {
        $self->cleanup_after_read( $key, $tmp_cfg{$key} );
    }

    # Lower casing all realms to find them consistently
    my $cfg = { map{lc($_) => $tmp_cfg{$_}} keys(%tmp_cfg) };

    return $cfg;

}

sub cleanup_after_read {
    my ( $self, $id, $item ) = @_;
    $self->expand_list( $item, $self->{expandable_params} );
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

