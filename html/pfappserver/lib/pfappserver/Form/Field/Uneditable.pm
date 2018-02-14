package pfappserver::Form::Field::Uneditable;

=head1 NAME

pfappserver::Form::Field::Uneditable - non-editable pseudo-field

=head1 DESCRIPTION

This field extends Text and uses the span widget to render
the field.

=cut

use Moose;
extends 'HTML::FormHandler::Field::Text';
use namespace::autoclean;

has '+widget' => ( default => 'Span' );
has 'escape_value' => ( default => 1, is => 'rw');

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
