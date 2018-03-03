package pf::ConfigStore::DeviceRegistration;
=head1 NAME

pf::ConfigStore::DeviceRegistration add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::DeviceRegistration

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($device_registration_config_file);
use pf::util;
extends 'pf::ConfigStore';
with 'pf::ConfigStore::Role::ReverseLookup';

sub configFile { $device_registration_config_file };

sub pfconfigNamespace {'config::DeviceRegistration'}

=head2 canDelete

canDelete

=cut

sub canDelete {
    my ($self, $id) = @_;
    return !$self->isInProfile('device_registration', $id) && $self->SUPER::canDelete($id);
}

=head2 cleanupAfterRead

Clean up data

=cut

sub cleanupAfterRead {
    my ($self, $id, $data) = @_;
    $self->expand_list($data, $self->_fields_expanded);
}

=head2 cleanupBeforeCommit

Clean data before update or creating

=cut

sub cleanupBeforeCommit {
    my ($self, $id, $data) = @_;
    my $real_id = $self->_formatSectionName($id);
    my $config = $self->cachedConfig;
    # Clear the section of any previous values
    $config->ClearSection($real_id);
    $self->flatten_list($data, $self->_fields_expanded);
}

=head2 _fields_expanded

=cut

sub _fields_expanded {
    return qw(allowed_devices);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

