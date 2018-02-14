package pfappserver::Form::Field::Regex;

=head1 NAME

pfappserver::Form::Field::Regex - A regex field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input value is an valid regex

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util;
use namespace::autoclean;


our $class_messages = {
    'regex' => 'It must be a valid regex',
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
         return eval { qr/$value/ };
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('regex');
     },
    }
   ]
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
