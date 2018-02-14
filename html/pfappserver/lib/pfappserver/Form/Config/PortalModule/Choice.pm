package pfappserver::Form::Config::PortalModule::Choice;

=head1 NAME

pfappserver::Form::Config::PortalModule:Choice

=head1 DESCRIPTION

Form definition to create or update a choice portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form::PortalModule::ModuleManager';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Choice;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Choice'}
## Definition

has_field 'show_first_module_on_default' =>
  (
   type => 'Toggle',
   label => 'Show first module when none is selected',
   unchecked_value => 'disabled',
   checkbox_value => 'enabled',
   default => for_module->meta->get_attribute('show_first_module_on_default')->default->(),
  );

has_field 'template' =>
  (
   type => 'Text',
   label => 'Template',
   default => for_module->meta->get_attribute('template')->default->(),
   tags => { after_element => \&help,
             help => 'The template to use to display the choices' },
  );


sub child_definition {
    return qw(show_first_module_on_default template);
}

sub BUILD {
    my ($self) = @_;
    $self->field('template')->default($self->for_module->meta->find_attribute_by_name('template')->default->());
    $self->field('show_first_module_on_default')->default($self->for_module->meta->find_attribute_by_name('show_first_module_on_default')->default->());
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

