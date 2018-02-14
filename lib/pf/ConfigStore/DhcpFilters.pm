package pf::ConfigStore::DhcpFilters;

=head1 NAME

pf::ConfigStore::DhcpFilters
Store dhcp filter rules

=cut

=head1 DESCRIPTION

pf::ConfigStore::DhcpFilters

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($dhcp_filters_config_file);
extends 'pf::ConfigStore';

sub configFile { $dhcp_filters_config_file };

sub pfconfigNamespace {'config::DhcpFilters'}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
