package pfappserver::Form::Field::Toggle;

=head1 NAME

pfappserver::Form::Field::Toggle - checkbox specific to PacketFence

=head1 DESCRIPTION

This field extends the default Checkbox. It is checked if the input
value matches the checkbox_value attribute.

=cut

use Moose;
extends 'HTML::FormHandler::Field::Checkbox';
use pf::config;
use namespace::autoclean;

has '+checkbox_value' => ( default => 'Y' );
has 'unchecked_value' => ( is => 'ro', default => 'N' );
has '+inflate_default_method'=> ( default => sub { \&toggle_inflate } );
has '+deflate_value_method'=> ( default => sub { \&toggle_deflate } );

sub toggle_inflate {
    my ($self, $value) = @_;

    return $self->{checkbox_value} if (pf::config::isenabled($value));
    return $self->{unchecked_value};
}

sub toggle_deflate {
    my ($self, $value) = @_;

    return $self->{checkbox_value} if (pf::config::isenabled($value));
    return $self->{unchecked_value};
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
