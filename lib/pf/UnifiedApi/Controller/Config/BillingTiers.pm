package pf::UnifiedApi::Controller::Config::BillingTiers;

=head1 NAME

pf::UnifiedApi::Controller::Config::BillingTiers - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::BillingTiers



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::BillingTiers';
has 'form_class' => 'pfappserver::Form::Config::BillingTiers';
has 'primary_key' => 'billing_tier_id';

use pf::ConfigStore::BillingTiers;
use pfappserver::Form::Config::BillingTiers;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

