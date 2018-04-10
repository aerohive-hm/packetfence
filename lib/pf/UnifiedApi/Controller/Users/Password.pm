package pf::UnifiedApi::Controller::Users::Password;

=head1 NAME

pf::UnifiedApi::Controller::Users::Password -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Users::Password

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::password;
has dal => 'pf::dal::password';
has url_param_name => 'user_id';
has primary_key => 'pid';

sub make_create_data {
    my ($self) = @_;
    my ($status, $data) = $self->SUPER::make_create_data();
    $data->{pid} = $self->stash->{user_id};
    return ($status, $data);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

