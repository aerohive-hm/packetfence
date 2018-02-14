package pfappserver::Form::Field::DatePicker;

=head1 NAME

pfappserver::Form::Field::DatePicker - to be used with the date picker
JavaScript widget

=head1 DESCRIPTION

This field is simply a text field to be formatted by a theme
(Form::Widget::Theme::Pf).

=cut

use Moose;
extends 'HTML::FormHandler::Field::Text';
use namespace::autoclean;
use pf::util;

has 'start' => ( is => 'rw', default => undef );
has 'end' => ( is => 'rw', default => undef );

=head2 validate

Validate all dates cannot exceed 2038-01-38

=cut

sub validate {
    my ($self) = @_;
    if (!validate_date($self->value)) {
        $self->add_error("Date shouldn't exceed 2038-01-18");
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
