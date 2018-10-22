package pf::UnifiedApi::Controller::Classes;

=head1 NAME

pf::UnifiedApi::Controller::Classes -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Classes

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::class;

has dal => 'pf::dal::class';
has url_param_name => 'class_id';
has primary_key => 'vid';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

