package pf::UnifiedApi::Controller::Config::AdminRoles;

=head1 NAME

pf::UnifiedApi::Controller::Config::AdminRoles -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::AdminRoles

=cut

use strict;
use warnings;
use Mojo::Base qw(pf::UnifiedApi::Controller::Config);
use pf::ConfigStore::AdminRoles;
use pfappserver::Form::Config::AdminRoles;

has 'config_store_class' => 'pf::ConfigStore::AdminRoles';
has 'form_class' => 'pfappserver::Form::Config::AdminRoles';
has 'primary_key' => 'admin_role_id';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

