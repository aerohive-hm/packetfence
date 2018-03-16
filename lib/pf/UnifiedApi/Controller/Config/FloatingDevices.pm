package pf::UnifiedApi::Controller::Config::FloatingDevices;

=head1 NAME

pf::UnifiedApi::Controller::Config::FloatingDevices - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::FloatingDevices



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::FloatingDevice';
has 'form_class' => 'pfappserver::Form::Config::FloatingDevice';
has 'primary_key' => 'floating_device_id';

use pf::ConfigStore::FloatingDevice;
use pfappserver::Form::Config::FloatingDevice;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

