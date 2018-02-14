package pfappserver::Form::Field::IP6Address;

=head1 NAME

pfappserver::Form::Field::IP6Address

=head1 DESCRIPTION

This field extends the default Text field and checks if the input
value is a valid IPv6 address.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util::IP;
use namespace::autoclean;

# If the field value matches one of the values defined in "accept", the field will pass validation.
# Otherwise, the field value must be a valid IPv6 address.
has 'accept' => ( is => 'rw', isa => 'ArrayRef' );

our $class_messages = {
    'ipv6' => 'Value must be an IPv6 address',
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
         return 1 if ($field->accept && grep { $_ eq $value } @{$field->accept});
         return (1) if pf::util::IP::is_ipv6($value);
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('ipv6');
     },
    }
   ]
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
