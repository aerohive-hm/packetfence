package pf::ConfigStore::FloatingDevice;

=head1 NAME

pf::ConfigStore::FloatingDevice add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::FloatingDevice

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moo;
use namespace::autoclean;
use pf::file_paths qw($floating_devices_config_file);
extends 'pf::ConfigStore';


sub configFile { $floating_devices_config_file }

sub pfconfigNamespace {'config::FloatingDevices'}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

