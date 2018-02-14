package pfappserver::Base::Controller::Crud::Clone;
=head1 NAME

pfappserver::Base::Controller::Crud::Clone

=head1 DESCRIPTION

Clone role for Crud controller

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants is_error is_success);
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

=head1 METHODS

=head2 clone

clone action for crud style controllers

=cut

sub clone :Chained('object') :PathPart('clone') :Args(0) {
    my ( $self, $c ) = @_;
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    my $idKey = $model->idKey;
    my $item = $c->stash->{$itemKey};
    $c->stash->{cloned_id} = $item->{$idKey};
    if ($c->request->method eq 'POST') {
        $self->_processCreatePost($c);
    }
    else {
        delete $item->{$idKey};
        my $form = $self->getForm($c);
        $form->process(init_object => $item);
        $c->stash(form => $form);
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

