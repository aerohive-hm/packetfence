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
    $self->{child_resources} = ['resource::ProvisioningReverseLookup'];
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{ $self->{cfg} };
    my %reverseLookup;

    while ( my ($key, $provisioner) = each %tmp_cfg) {
        $self->cleanup_after_read($key, $provisioner);
        foreach my $field (qw(pki_provider)) {
            my $values = $provisioner->{$field};
            if (ref ($values) eq '') {
                next if !defined $values || $values eq '';

                $values = [$values];
            }

            for my $val (@$values) {
                push @{$reverseLookup{$field}{$val}}, $key;
            }
        }
    }
    $self->{reverseLookup} = \%reverseLookup;

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

