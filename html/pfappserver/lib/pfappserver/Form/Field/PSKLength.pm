package pfappserver::Form::Field::PSKLength;

=head1 NAME

pfappserver::Form::Field::PSKLength - PSKLength field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input
value is geater or equal to 8.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Integer';

use pf::util;
use namespace::autoclean;

our $class_messages = {
    'psk_length' => 'Value must be greater or equal to 8',
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
        check   => sub { $_[0] >= 8 },
        message => sub {
            my ( $value, $field ) = @_;
            return $field->get_message('psk_length');
        },
    },
];

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
