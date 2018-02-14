package pfappserver::Form::Field::IPAddresses;

=head1 NAME

pfappserver::Form::Field::IPAddresses - IP addresses input field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input
value is an IP addresses.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util;
use namespace::autoclean;

# If the field value matches one of the values defined in "accept", the field will pass validation.
# Otherwise, the field value must be a valid IPv4 address.
has 'accept' => ( is => 'rw', isa => 'ArrayRef' );

our $class_messages = {
    'ipv4' => 'Value must be an IPv4 address',
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
         return valid_ips( $value );
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('ipv4');
     },
    }
   ]
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
