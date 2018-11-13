package pf::ConfigStore::Interface;

=head1 NAME

pf::ConfigStore::Profile

=head1 DESCRIPTION

pf::ConfigStore::Switch

=cut

use Moo;
use namespace::autoclean;
use pf::ConfigStore::Pf;
use pf::ConfigStore::Group;
use pf::file_paths qw($pf_config_file);

extends 'pf::ConfigStore';
with 'pf::ConfigStore::Group';

sub group { 'interface' };

sub pfconfigNamespace {'config::Pf'};

sub configFile {$pf_config_file};

=head1 METHODS

=head2 _buildCachedConfig

  Build the cached config

=cut

sub _buildCachedConfig { pf::ConfigStore::Pf->new->cachedConfig() }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
