package pfappserver::Form::Config::PortalModule::URL;

=head1 NAME

pfappserver::Form::Config::PortalModule:URL

=head1 DESCRIPTION

Form definition to create or update a URL module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::URL;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::URL'}
## Definition

has_field 'skipable' =>
  (
   type => 'Toggle',
   label => 'Skippable',
   unchecked_value => '0',
   checkbox_value => '1',
   tags => { after_element => \&help,
             help => 'Whether or not, this redirection can be skipped.' },
  );

has_field 'url' =>
  (
   type => 'Text',
   label => 'URL',
   required => 1,
   tags => { after_element => \&help,
             help => 'The URL on which the user should be redirected.' },
  );

=head2 child_definition

Which fields defined the form

=cut

sub child_definition {
    return qw(url skipable);
}

=head2 BUILD

Override BUILD method to set the default value of the skipable field

=cut

sub BUILD {
    my ($self) = @_;
    $self->field('skipable')->default($self->for_module->meta->find_attribute_by_name('skipable')->default->());
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;


