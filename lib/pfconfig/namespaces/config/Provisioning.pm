package pfconfig::namespaces::config::Provisioning;

=head1 NAME

pfconfig::namespaces::config::Provisioning

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Provisioning

This module creates the configuration hash associated to provisioning.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($provisioning_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $provisioning_config_file;
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };

    foreach my $key ( keys %tmp_cfg ) {
        $self->cleanup_after_read( $key, $tmp_cfg{$key} );
    }

    return \%tmp_cfg;

}

sub cleanup_after_read {
    my ( $self, $id, $data ) = @_;
    $self->expand_list( $data, qw(category oses) );
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

