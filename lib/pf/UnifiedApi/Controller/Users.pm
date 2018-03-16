package pf::UnifiedApi::Controller::Users;

=head1 NAME

pf::UnifiedApi::Controller::User -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::User

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::person;

has dal => 'pf::dal::person';
has url_param_name => 'user_id';
has primary_key => 'pid';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

