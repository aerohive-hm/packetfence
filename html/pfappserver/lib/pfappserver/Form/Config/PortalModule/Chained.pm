package pfappserver::Form::Config::PortalModule::Chained;

=head1 NAME

pfappserver::Form::Config::PortalModule::Chained

=head1 DESCRIPTION

Form definition to create or update a Chained portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form::PortalModule::ModuleManager';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Chained;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Chained'}

## Definition

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

