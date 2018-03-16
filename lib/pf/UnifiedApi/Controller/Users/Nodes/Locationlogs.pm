package pf::UnifiedApi::Controller::Users::Nodes::Locationlogs;

=head1 NAME

pf::UnifiedApi::Controller::Users::Nodes::Locationlogs -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Users::Nodes::Locationlogs

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::locationlog;

has 'dal' => 'pf::dal::locationlog';
has 'url_param_name' => 'locationlog_id';
has 'primary_key' => 'id';
has 'parent_primary_key_map' => sub { {node_id => 'mac'} };

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

