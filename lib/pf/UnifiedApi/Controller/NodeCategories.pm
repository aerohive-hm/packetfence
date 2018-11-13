package pf::UnifiedApi::Controller::NodeCategories;

=head1 NAME

pf::UnifiedApi::Controller::NodeCategories -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::NodeCategories

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::node_category;

has dal => 'pf::dal::node_category';
has url_param_name => 'node_category_id';
has primary_key => 'id';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

