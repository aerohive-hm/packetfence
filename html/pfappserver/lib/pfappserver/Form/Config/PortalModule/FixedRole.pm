package pfappserver::Form::Config::PortalModule::FixedRole;

=head1 NAME

pfappserver::Form::Config::PortalModule:FixedRole

=head1 DESCRIPTION

Form definition to create or update a Role in stone portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';
with 'pfappserver::Base::Form::Role::Help';

use pf::nodecategory;

use captiveportal::DynamicRouting::Module::FixedRole;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::FixedRole'}
## Definition

has_field 'stone_roles' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Roles',
   options_method => \&options_stone_role,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add a role'},
   tags => { after_element => \&help,
             help => 'Nodes with the selected roles will be affected' },
  );

sub child_definition {
    return qw(stone_roles);
}

sub options_stone_role {
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


