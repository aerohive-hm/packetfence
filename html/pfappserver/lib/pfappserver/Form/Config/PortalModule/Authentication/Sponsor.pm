package pfappserver::Form::Config::PortalModule::Authentication::Sponsor;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::Sponsor

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Authentication::Sponsor;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::Sponsor'}

## Definition

has_field 'forced_sponsor' =>
  (
   type => 'Text',
   label => 'Forced Sponsor',
   tags => { after_element => \&help,
             help => 'Defines the sponsor email used. Leave empty so that the user has to specify a sponsor.' },
  );

=head2 auth_module_definition

Overriding to add the forced sponsor option

=cut

sub auth_module_definition {
    my ($self) = @_;
    return (qw(forced_sponsor));
}
=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
