package pfappserver::Form::Config::PortalModule::Message;

=head1 NAME

pfappserver::Form::Config::PortalModule:Choice

=head1 DESCRIPTION

Form definition to create or update a choice portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Message;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Message'}
## Definition

has_field 'skipable' =>
  (
   type => 'Toggle',
   label => 'Skippable',
   unchecked_value => '0',
   checkbox_value => '1',
   tags => { after_element => \&help,
             help => 'Whether or not, this message can be skipped' },
  );

has_field 'message' =>
  (
   type => 'TextArea',
   label => 'Message',
   element_class => ['input-xxlarge'],
   required => 1,
   tags => { after_element => \&help,
             help => 'The message that will be displayed to the user. Use with caution as the HTML contained in this field will NOT be escaped.' },
  );

has_field 'template' =>
  (
   type => 'Text',
   label => 'Template',
   tags => { after_element => \&help,
             help => 'The template to use to display the message' },
  );

sub child_definition {
    return qw(message template skipable);
}

sub BUILD {
    my ($self) = @_;
    $self->field('template')->default($self->for_module->meta->find_attribute_by_name('template')->default->());
    $self->field('skipable')->default($self->for_module->meta->find_attribute_by_name('skipable')->default->());
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;


