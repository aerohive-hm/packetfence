package pfappserver::Form::Config::PortalModule::Authentication::OAuth;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::OAuth

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Authentication::OAuth;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth'}

has_field '+signup_template' => ( required => 0 );

has_field 'landing_template' =>
  (
   type => 'Text',
   label => 'Landing template',
   required => 1,
   tags => { after_element => \&help,
             help => 'The template to use for the signup' },
  );

=head2 BUILD

set the default value for for fields

=cut

sub BUILD {
    my ($self) = @_;
    $self->field('landing_template')->default($self->for_module->meta->find_attribute_by_name('landing_template')->default->());
}

=head2 child_definition

The fields to display

=cut

sub child_definition {
    my ($self) = @_;
    return (qw(source_id with_aup aup_template landing_template));
}

## Definition

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
