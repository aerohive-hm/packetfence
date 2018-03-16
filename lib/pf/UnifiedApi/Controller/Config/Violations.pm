package pf::UnifiedApi::Controller::Config::Violations;

=head1 NAME

pf::UnifiedApi::Controller::Config::Violations - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Violations



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::Violations';
has 'form_class' => 'pfappserver::Form::Violation';
has 'primary_key' => 'violation_id';

use pf::ConfigStore::Violations;
use pfappserver::Form::Violation;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

