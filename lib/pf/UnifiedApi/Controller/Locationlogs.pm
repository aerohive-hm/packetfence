package pf::UnifiedApi::Controller::Locationlogs;

=head1 NAME

pf::UnifiedApi::Controller::Locationlogs -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Locationlogs

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::locationlog;
use pf::SQL::Abstract;
use pf::UnifiedApi::Search;
use pf::error qw(is_error);

has dal => 'pf::dal::locationlog';
has url_param_name => 'locationlog_id';
has primary_key => 'id';


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
