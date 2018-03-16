package pf::ConfigStore::TrafficShaping;

=head1 NAME

pf::ConfigStore::TrafficShaping

=cut

=head1 DESCRIPTION

pf::ConfigStore::TrafficShaping

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moo;
use namespace::autoclean;
use pf::file_paths qw($traffic_shaping_config_file);
extends 'pf::ConfigStore';

sub configFile { $traffic_shaping_config_file }

sub pfconfigNamespace { 'config::TrafficShaping' }


__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=cut

1;
