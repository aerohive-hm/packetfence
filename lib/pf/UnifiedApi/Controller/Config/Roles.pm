package pf::UnifiedApi::Controller::Config::Roles;

=head1 NAME

pf::UnifiedApi::Controller::Config::Roles - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Roles



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::Roles';
has 'form_class' => 'pfappserver::Form::Config::Roles';
has 'primary_key' => 'role_id';

use pf::ConfigStore::Roles;
use pfappserver::Form::Config::Roles;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

