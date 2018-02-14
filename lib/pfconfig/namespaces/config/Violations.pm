package pfconfig::namespaces::config::Violations;

=head1 NAME

pfconfig::namespaces::config::Violations

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Violations

This module creates the configuration hash associated to violations.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw(
    $violations_config_file
    $violations_default_config_file
);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file}            = $violations_config_file;
    $self->{default_section} = "defaults";
    $self->{child_resources} = [ 'FilterEngine::Violation' ];
    my $defaults = Config::IniFiles->new(-file => $violations_default_config_file);
    $self->{added_params}{'-import'} = $defaults;
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };

    $self->cleanup_whitespaces( \%tmp_cfg );

    foreach my $key ( keys %tmp_cfg ) {
        $self->cleanup_after_read( $key, $tmp_cfg{$key} );
    }

    return \%tmp_cfg;

}

sub cleanup_after_read {
    my ( $self, $id, $data ) = @_;
    $self->expand_list( $data, qw(whitelisted_roles) );
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

