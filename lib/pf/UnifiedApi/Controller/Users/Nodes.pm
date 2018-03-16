package pf::UnifiedApi::Controller::Users::Nodes;

=head1 NAME

pf::UnifiedApi::Controller::Users::Nodes -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Users::Nodes

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::person;

has 'dal' => 'pf::dal::node';
has 'url_param_name' => 'node_id';
has 'primary_key' => 'mac';
has 'parent_primary_key_map' => sub { {user_id => 'pid'} };

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
