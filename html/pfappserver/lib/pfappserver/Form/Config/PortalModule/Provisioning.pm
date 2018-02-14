package pfappserver::Form::Config::PortalModule::Provisioning;

=head1 NAME

pfappserver::Form::Config::PortalModule:Choice

=head1 DESCRIPTION

Form definition to create or update a choice portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Provisioning;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Provisioning'}
## Definition

has_field 'skipable' =>
  (
   type => 'Toggle',
   label => 'Skippable',
   unchecked_value => 'disabled',
   checkbox_value => 'enabled',
   tags => { after_element => \&help,
             help => 'Whether or not, the provisioning can be skipped' },
  );

sub BUILD {
    my ($self) = @_;
    $self->field('skipable')->default($self->for_module->meta->find_attribute_by_name('skipable')->default->());
}

sub child_definition {
    return qw(skipable);
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;


