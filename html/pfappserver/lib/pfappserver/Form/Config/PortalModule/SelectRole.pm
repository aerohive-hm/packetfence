package pfappserver::Form::Config::PortalModule::SelectRole;

=head1 NAME

pfappserver::Form::Config::PortalModule:Choice

=head1 DESCRIPTION

Form definition to create or update a choice portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';
with 'pfappserver::Base::Form::Role::Help';

use pf::nodecategory;

use captiveportal::DynamicRouting::Module::SelectRole;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::SelectRole'}
## Definition

has_field 'admin_role' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Admin role',
   options_method => \&options_admin_role,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add a role'},
   tags => { after_element => \&help,
             help => 'Which roles should have access to this module to select the role' },
  );

has_field 'template' =>
  (
   type => 'Text',
   label => 'Template',
   tags => { after_element => \&help,
             help => 'The template to use' },
  );

has_field 'list_role' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Role List',
   options_method => \&options_admin_role,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add a role'},
   tags => { after_element => \&help,
             help => 'Which roles can be select' },
  );

sub child_definition {
    return qw(admin_role list_role template);
}

sub BUILD {
    my ($self) = @_;
    $self->field('template')->default($self->for_module->meta->find_attribute_by_name('template')->default->());
}

sub options_admin_role {
    my $self = shift;
    my @roles = map { $_->{name} => $_->{name} } nodecategory_view_all();
    return @roles;
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;


