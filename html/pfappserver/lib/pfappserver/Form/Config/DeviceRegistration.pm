package pfappserver::Form::Config::DeviceRegistration;

=head1 NAME

pfappserver::Form::Config::DeviceRegistration - Web form for the device registration

=head1 DESCRIPTION

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

has roles => ( is => 'rw' );

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'Profile Name',
   required => 1,
   messages => { required => 'Please specify a name of the Device Registration entry.' },
   apply => [ pfappserver::Base::Form::id_validator('device registration ID') ]
  );

has_field 'description' =>
  (
   type => 'Text',
   messages => { required => 'Please specify the description of the Device Registration entry.' },
  );

has_field 'category' =>
  (
   type => 'Select',
   label => 'Role',
   options_method => \&options_roles,
   tags => { after_element => \&help,
             help => 'The role to assign to devices registered from the specific portal. If none is specified, the role of the registrant is used.' },
  );

has_field 'allowed_devices' =>
  (
   type => 'FingerbankSelect',
   multiple => 1,
   label => 'OS',
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add an OS'},
   tags => { after_element => \&help,
             help => 'List of OS which will be allowed to be register via the self service portal.' },
   fingerbank_model => "fingerbank::Model::Device",
  );

has_block definition =>
  (
   render_list => [ qw(id description category allowed_devices) ],
  );

=head2 options_roles

=cut

sub options_roles {
    my $self = shift;
    my @roles = map { $_->{name} => $_->{name} } @{$self->form->roles} if ($self->form->roles);
    return ('' => '', @roles);
}

=head2 ACCEPT_CONTEXT

To automatically add the context to the Form

=cut

sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    my ($status, $roles) = $c->model('Config::Roles')->listFromDB();
    return $self->SUPER::ACCEPT_CONTEXT($c, roles => $roles, @args);
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
