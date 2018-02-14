package pf::ConfigStore::DNS_Filters;

=head1 NAME

pf::ConfigStore::DNS_Filters add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::DNS_Filters

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($dns_filters_config_file);
extends 'pf::ConfigStore';

sub configFile { $dns_filters_config_file };

sub pfconfigNamespace {'config::DNS_Filters'}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
