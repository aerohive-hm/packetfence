package pfappserver::Base::Controller::Crud::Config::Clone;
=head1 NAME

pfappserver::Base::Controller::Crud::Config::Clone

=head1 DESCRIPTION

Clone role for Crud controller

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants is_error is_success);
use MooseX::MethodAttributes::Role;
use namespace::autoclean;
with 'pfappserver::Base::Controller::Crud::Clone';

=head1 METHODS

=head2 clone

clone action for crud style controllers

=cut

after clone => sub {
    my ($self,$c) = @_;
    if(is_success($c->response->status) && $c->request->method eq 'POST' ) {
        $self->_commitChanges($c);
    }
};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

