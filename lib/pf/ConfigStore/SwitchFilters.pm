package pf::ConfigStore::SwitchFilters;
=head1 NAME

pf::ConfigStore::SwitchFilters add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::SwitchFilters

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($switch_filters_config_file);
extends 'pf::ConfigStore';

sub configFile { $switch_filters_config_file };

sub pfconfigNamespace {'config::SwitchFilters'}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
