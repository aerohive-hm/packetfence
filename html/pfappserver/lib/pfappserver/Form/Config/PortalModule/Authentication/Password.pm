package pfappserver::Form::Config::PortalModule::Authentication::Password;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::Password

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Authentication::Password;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::Password'}

## Definition

has_field 'username' =>
  (
   type => 'Text',
   label => 'Username',
   required => 1,
   tags => { after_element => \&help,
             help => 'Defines the username used for all authentications' },
  );

=head2 auth_module_definition

Overriding to remove the username

=cut

sub auth_module_definition {
    my ($self) = @_;
    return (qw(username));
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
