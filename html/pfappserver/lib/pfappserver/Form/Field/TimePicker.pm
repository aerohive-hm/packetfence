package pfappserver::Form::Field::TimePicker;

=head1 NAME

pfappserver::Form::Field::TimePicker - to be used with the time picker
JavaScript widget

=head1 DESCRIPTION

This field is simply a text field to be formatted by a theme
(Form::Widget::Theme::Pf).

=cut

use Moose;
extends 'HTML::FormHandler::Field::Text';
use namespace::autoclean;

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
