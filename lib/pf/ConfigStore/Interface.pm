package pf::ConfigStore::Interface;
=head1 NAME

pf::ConfigStore::Profile add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::Switch;

=cut

use Moo;
use namespace::autoclean;
use pf::ConfigStore::Pf;
use pf::ConfigStore::Group;

extends 'pf::ConfigStore';
with 'pf::ConfigStore::Group';

sub group { 'interface' };

sub pfconfigNamespace {'config::Pf'};

=head2 Methods

=over

=item _buildCachedConfig

=cut

sub _buildCachedConfig { pf::ConfigStore::Pf->new->cachedConfig() }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
