package pf::UnifiedApi::Controller::Tenants;

=head1 NAME

pf::UnifiedApi::Controller::Tenants -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Tenants

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::tenant;

has dal => 'pf::dal::tenant';
has url_param_name => 'tenant_id';
has primary_key => 'id';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

