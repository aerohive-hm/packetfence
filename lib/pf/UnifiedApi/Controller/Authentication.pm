package pf::UnifiedApi::Controller::Authentication;

=head1 NAME

pf::UnifiedApi::Controller::Authentication -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Authentication

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller';
use pf::error qw(is_error);
use pf::authentication;
use pf::Authentication::constants qw($LOGIN_SUCCESS);

sub adminAuthentication {
    my ($self) = @_;
    
    my ($status, $json) = $self->parse_json;
    if (is_error($status)) {
        $self->render(status => $status, json => $json);
    }

    my ($result, $roles, $tenant_id) = pf::authentication::adminAuthentication($json->{username}, $json->{password});

    if($result == $LOGIN_SUCCESS) {
        $self->render(status => 200, json => { result => $result, roles => $roles, tenant_id => int($tenant_id) });
    }
    else {
        $self->render(status => 401, json => { result => $result, message => "Authentication failed." })
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

