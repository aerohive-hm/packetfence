package pfappserver::Form::Field::Path;

=head1 NAME

pfappserver::Form::Field::Path - A path field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input value is an valid path

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util;
use namespace::autoclean;

# If the field value matches one of the values defined in "accept", the field will pass validation.
# Otherwise, the field value must be a valid IPv4 address.

our $class_messages = {
    'path' => 'It must be a valid path',
};

sub get_class_messages {
    my $self = shift;
    return {
       %{ $self->next::method },
       %$class_messages,
    }
}

apply
  (
   [
    {
     check => sub {
         my ( $value, $field ) = @_;
         return -e $value;
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('path');
     },
    }
   ]
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
