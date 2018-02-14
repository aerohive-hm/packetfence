package pfappserver::Form::Field::SwitchID;

=head1 NAME

pfappserver::Form::Field::IPAddress - IP address input field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input
value is an IP address.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util;
use namespace::autoclean;

# If the field value matches one of the values defined in "accept", the field will pass validation.
# Otherwise, the field value must be a valid IPv4 address.
has 'accept' => ( is => 'rw', isa => 'ArrayRef' );

our $class_messages = {
    'switch_id' => 'Value must be an IPv4 address or a mac address',
};

sub get_class_messages {
    my $self = shift;
    return {
       %{ $self->next::method },
       %$class_messages,
    }
}

apply
[
    {
        check => sub {
            my ( $value, $field ) = @_;
            return 1 if ($field->accept && grep { $_ eq $value } @{$field->accept});
            return 1 if valid_ip_range( $value );
            return valid_mac_or_ip( $value );
        }
    },
    {
        message => sub {
            my ( $value, $field ) = @_;
            return $field->get_message('switch_id');
        },
    },
    {
        transform => sub {
            my ($val) = @_;
            return clean_mac( $val ) if !valid_ip($val) && valid_mac($val);
            return $val;
        }
    }
];

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
