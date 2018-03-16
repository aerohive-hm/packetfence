package pf::UnifiedApi::Controller::Config::Realms;

=head1 NAME

pf::UnifiedApi::Controller::Config::Realms - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Realms



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::Realm';
has 'form_class' => 'pfappserver::Form::Config::Realm';
has 'primary_key' => 'realm_id';

use pf::ConfigStore::Realm;
use pfappserver::Form::Config::Realm;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

