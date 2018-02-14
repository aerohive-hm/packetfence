package pf::ConfigStore::RadiusFilters;
=head1 NAME

pf::ConfigStore::RadiusFilters
Store radius filter rules

=cut

=head1 DESCRIPTION

pf::ConfigStore::RadiusFilters

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($radius_filters_config_file);
extends 'pf::ConfigStore';

sub configFile { $radius_filters_config_file };

sub pfconfigNamespace {'config::RadiusFilters'}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

