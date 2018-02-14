package pf::ConfigStore::Roles;
=head1 NAME

pf::ConfigStore::Roles

=cut

=head1 DESCRIPTION

Store and manipulate roles configuration

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($roles_config_file $roles_default_config_file);
use pf::nodecategory;
use pf::config;
extends 'pf::ConfigStore';

sub configFile { $roles_config_file };
sub importConfigFile { $roles_default_config_file }

sub pfconfigNamespace {'config::Roles'}

=item commit

Repopulate the node_category table after commiting

=cut

sub commit {
    my ($self) = @_;
    my ($result, $error) = $self->SUPER::commit();
    pf::log::get_logger->info("commiting via Roles configstore");
    nodecategory_populate_from_config( \%pf::config::ConfigRoles );
    return ($result, $error);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


