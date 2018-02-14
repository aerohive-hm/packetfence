package pf::ConfigStore::PKI_Provider;

=head1 NAME

pf::ConfigStore::PKI_Provider

=cut

=head1 DESCRIPTION

pf::ConfigStore::PKI_Provider

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moo;
use namespace::autoclean;
use pf::file_paths qw($pki_provider_config_file);
extends 'pf::ConfigStore';

sub configFile { $pki_provider_config_file }

sub pfconfigNamespace { 'config::PKI_Provider' }


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
