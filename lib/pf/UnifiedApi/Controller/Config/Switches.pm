package pf::UnifiedApi::Controller::Config::Switches;

=head1 NAME

pf::UnifiedApi::Controller::Config::Switches - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Switches



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::Switch';
has 'form_class' => 'pfappserver::Form::Config::Switch';
has 'primary_key' => 'switch_id';

use pf::ConfigStore::Switch;
use pfappserver::Form::Config::Switch;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

