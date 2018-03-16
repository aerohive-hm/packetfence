package pf::ConfigStore::Role::ReverseLookup;

=head1 NAME

pf::ConfigStore::Role::ReverseLookup -

=cut

=head1 DESCRIPTION

pf::ConfigStore::Role::ReverseLookup

=cut

use strict;
use warnings;
use Moo::Role;
use pfconfig::cached_hash;
tie our %ProfileReverseLookup, 'pfconfig::cached_hash', 'resource::ProfileReverseLookup';
tie our %PortalModuleReverseLookup, 'pfconfig::cached_hash', 'resource::PortalModuleReverseLookup';
tie our %ProvisioningReverseLookup, 'pfconfig::cached_hash', 'resource::ProvisioningReverseLookup';
tie our %SwitchReverseLookup, 'pfconfig::cached_hash', 'resource::SwitchReverseLookup';

sub isInProfile {
    my ($self, $namespace, $id) = @_;
    return exists $ProfileReverseLookup{$namespace}{$id};
}

sub isInPortalModules {
    my ($self, $namespace, $id) = @_;
    return exists $PortalModuleReverseLookup{$namespace}{$id};
}

sub isInProvisioning {
    my ($self, $namespace, $id) = @_;
    return exists $ProvisioningReverseLookup{$namespace}{$id};
}

sub isInSwitch {
    my ($self, $namespace, $id) = @_;
    return exists $SwitchReverseLookup{$namespace}{$id};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
