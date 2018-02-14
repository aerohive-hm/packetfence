package pfappserver::Form::Config::Provisioning;

=head1 NAME

pfappserver::Form::Config::Provisioning - Web form for a switch

=head1 DESCRIPTION

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

use pf::config qw(%ConfigPKI_Provider);

has roles => ( is => 'rw' );
has violations => ( is => 'rw');

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'Provisioning ID',
   required => 1,
   messages => { required => 'Please specify the ID of the Provisioning entry.' },
   apply => [ pfappserver::Base::Form::id_validator('provisioning ID') ]
  );

has_field 'description' =>
  (
   type => 'Text',
   messages => { required => 'Please specify the Description Provisioning entry.' },
  );

has_field 'type' =>
  (
   type => 'Hidden',
   label => 'Provisioning type',
   required => 1,
   messages => { required => 'Please select Provisioning type' },
  );

has_field 'category' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Roles',
   options_method => \&options_roles,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add a role'},
   tags => { after_element => \&help,
             help => 'Nodes with the selected roles will be affected' },
  );

has_field 'oses' =>
  (
   type => 'FingerbankSelect',
   multiple => 1,
   label => 'OS',
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add an OS'},
   tags => { after_element => \&help,
             help => 'Nodes with the selected OS will be affected' },
   fingerbank_model => "fingerbank::Model::Device",
  );

has_field 'non_compliance_violation' =>
  (
   type => 'Select',
   label => 'Non compliance violation',
   options_method => \&options_violations,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'None'},
   tags => { after_element => \&help,
             help => 'Which violation should be raised when non compliance is detected' },
  );

has_field 'pki_provider' =>
  (
   type => 'Select',
   label => 'PKI Provider',
   options_method => \&options_pki_provider,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'None'},
  );

has_block definition =>
  (
   render_list => [ qw(id type description category pki_provider oses) ],
  );

=head2 options_pki_provider

=cut

sub options_pki_provider {
    return { value => '', label => '' }, map { { value => $_, label => $_ } } sort keys %ConfigPKI_Provider;
}

=head2 options_roles

=cut

sub options_roles {
    my $self = shift;
    my @roles = map { $_->{name} => $_->{name} } @{$self->form->roles} if ($self->form->roles);
    return @roles;
}

sub options_violations {
    my $self = shift;
    my @violations;
    foreach my $violation (@{$self->form->violations}){
        push @violations, $violation->{id};
        push @violations, $violation->{desc};
    }
    return @violations;
}

=head2 ACCEPT_CONTEXT

To automatically add the context to the Form

=cut

sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    my ($status, $roles) = $c->model('Config::Roles')->listFromDB();
    my (undef, $violations) = $c->model('Config::Violations')->readAll();
    return $self->SUPER::ACCEPT_CONTEXT($c, roles => $roles, violations => $violations, @args);
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
