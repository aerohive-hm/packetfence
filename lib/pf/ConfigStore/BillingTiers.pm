package pf::ConfigStore::BillingTiers;
=head1 NAME

pf::ConfigStore::BillingTiers

=cut

=head1 DESCRIPTION

pf::ConfigStore::BillingTiers

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($billing_tiers_config_file);
extends 'pf::ConfigStore';
with 'pf::ConfigStore::Role::ReverseLookup';

sub configFile { $billing_tiers_config_file };

sub pfconfigNamespace {'config::BillingTiers'}

=head2 canDelete

canDelete

=cut

sub canDelete {
    my ($self, $id) = @_;
    return !$self->isInProfile('billing_tiers', $id) && $self->SUPER::canDelete($id);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

