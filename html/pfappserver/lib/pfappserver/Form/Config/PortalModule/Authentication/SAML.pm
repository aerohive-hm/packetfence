package pfappserver::Form::Config::PortalModule::Authentication::SAML;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::SAML

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';

use captiveportal::DynamicRouting::Module::Authentication::SAML;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::SAML'}

## Definition

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
