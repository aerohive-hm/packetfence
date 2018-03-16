package pf::UnifiedApi::Controller::ApiUsers;

=head1 NAME

pf::UnifiedApi::Controller::ApiUser -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::ApiUser

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::api_user;
use pf::error qw(is_error);

has dal => 'pf::dal::api_user';
has url_param_name => 'user_id';
has primary_key => 'username';

sub make_create_data {
    my ($self) = @_;
    my ($status, $data) = $self->SUPER::make_create_data();
    if (is_error($status)) {
        return ($status, $data);
    }
    $data->{'-no_auto_tenant_id'} = 1;
    return ($status, $data);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

