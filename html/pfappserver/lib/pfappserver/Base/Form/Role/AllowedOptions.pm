package pfappserver::Base::Form::Role::AllowedOptions;

=head1 NAME

pfappserver::Base::Form::Role::AllowedOptions -

=cut

=head1 DESCRIPTION

pfappserver::Base::Form::Role::AllowedOptions

=cut

use namespace::autoclean;
use HTML::FormHandler::Moose::Role;

use pf::admin_roles;

=head2 _get_allowed_options

Get the allowed options for the current user based off their role.

=cut

sub _get_allowed_options {
    my ($self, $option) = @_;
    return admin_allowed_options([$self->ctx->user->roles], $option);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

