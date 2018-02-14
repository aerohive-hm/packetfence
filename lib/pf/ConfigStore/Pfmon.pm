package pf::ConfigStore::Pfmon;

=head1 NAME

pf::ConfigStore::Pfmon

=cut

=head1 DESCRIPTION

pf::ConfigStore::Pfmon

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moo;
use namespace::autoclean;
use pf::file_paths qw($pfmon_config_file $pfmon_default_config_file);
extends 'pf::ConfigStore';

sub configFile { $pfmon_config_file }

sub importConfigFile { $pfmon_default_config_file }

sub pfconfigNamespace { 'config::Pfmon' }


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
