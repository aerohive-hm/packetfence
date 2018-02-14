package pfappserver::Form::Field::MACAddress;

=head1 NAME

pfappserver::Form::Field::MACAddress - MAC address input field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input
value is a MAC address.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util;
use namespace::autoclean;

our $class_messages = {
    'mac' => 'Value must be a MAC address',
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
         return valid_mac( $value );
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('mac');
     },
    },
    {
     transform => sub {
         my ($value, $field ) = @_;
         return clean_mac($value);
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('mac');
     },
    }
   ]
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
