package pf::UnifiedApi::Controller::Config::TrafficShapingPolicies;

=head1 NAME

pf::UnifiedApi::Controller::Config::TrafficShapingPolicies - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::TrafficShapingPolicies



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::TrafficShaping';
has 'form_class' => 'pfappserver::Form::Config::TrafficShaping';
has 'primary_key' => 'traffic_shaping_id';

use pf::ConfigStore::TrafficShaping;
use pfappserver::Form::Config::TrafficShaping;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

