package pf::UnifiedApi::Controller::Config::Domains;

=head1 NAME

pf::UnifiedApi::Controller::Config::Domains -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Domains

=cut

use strict;
use warnings;

use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::Domain';
has 'form_class' => 'pfappserver::Form::Config::Domain';
has 'primary_key' => 'domain_id';

use pf::ConfigStore::Domain;
use pfappserver::Form::Config::Domain;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
