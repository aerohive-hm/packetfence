package pf::UnifiedApi::Controller::Config::SwitchGroups;

=head1 NAME

pf::UnifiedApi::Controller::Config::SwitchGroups - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::SwitchGroups



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::SwitchGroup';
has 'form_class' => 'pfappserver::Form::Config::SwitchGroup';
has 'primary_key' => 'switch_group_id';

use pf::ConfigStore::SwitchGroup;
use pfappserver::Form::Config::SwitchGroup;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

