package pf::ConfigStore::Domain;
=head1 NAME

pf::ConfigStore::Domain
Store Domain configuration

=cut

=head1 DESCRIPTION

pf::ConfigStore::Domain

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($domain_config_file);
extends 'pf::ConfigStore';

sub configFile { $domain_config_file };

sub pfconfigNamespace {'config::Domain'}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

