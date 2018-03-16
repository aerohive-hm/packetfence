package pf::UnifiedApi::Controller::RestRoute;

=head1 NAME

pf::UnifiedApi::Controller::RestRoute -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::RestRoute

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller';

sub list {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub resource {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub get {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub create {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub remove {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub update {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub replace {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

sub search {
    my ($self) = @_;
    return $self->render_error(404, "Unimplemented");
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

