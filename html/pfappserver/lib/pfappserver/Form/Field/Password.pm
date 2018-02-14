package pfappserver::Form::Field::Password;

=head1 NAME

pfappserver::Form::Field::Password - PacketFence password field

=head1 DESCRIPTION

This field extends Password to avoid autocompletion of all the password fields

=cut

use Moose;
extends 'HTML::FormHandler::Field::Password';
use namespace::autoclean;

has '+password' => ( default => 0 );

sub build_element_attr {
    return { autocomplete => 'off', readonly => 1 , 'data-pf-toggle' => 'password' };
}
=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
