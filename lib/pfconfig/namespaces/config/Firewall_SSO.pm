package pfconfig::namespaces::config::Firewall_SSO;

=head1 NAME

pfconfig::namespaces::config::template

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::template

This module creates the configuration hash associated to firewall_sso.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pfconfig::objects::NetAddr::IP;
use pf::file_paths qw($firewall_sso_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $firewall_sso_config_file;
}

sub build_child {
    my ($self) = @_;
    my %tmp_cfg = %{ $self->{cfg} };

    foreach my $key ( keys %tmp_cfg ) {
        $self->cleanup_after_read( $key, $tmp_cfg{$key} );
        my @networks = map { pfconfig::objects::NetAddr::IP->new($_) } @{$tmp_cfg{$key}{networks}};
        $tmp_cfg{$key}{networks} = \@networks;
    }

    return \%tmp_cfg;

}

sub cleanup_after_read {
    my ( $self, $id, $data ) = @_;
    $self->expand_list( $data, qw(categories networks) );
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

