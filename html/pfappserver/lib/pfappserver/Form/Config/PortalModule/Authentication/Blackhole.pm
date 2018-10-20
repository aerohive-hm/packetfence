package pfappserver::Form::Config::PortalModule::Authentication::Blackhole;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::Blackhole

=head1 DESCRIPTION

Form definition to create or update an authentication blackhole portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Authentication::Blackhole;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::Blackhole'}

has_field 'template' =>
  (
   type => 'Text',
   label => 'Template',
   tags => { after_element => \&help,
             help => 'The template to use' },
  );

before 'setup' => sub {
    my ($self) = @_;
    $self->remove_field($_) for (qw(pid_field with_aup aup_template signup_template actions));
};

sub auth_module_definition {
    return qw(template);
}

sub BUILD {
    my ($self) = @_;
    $self->field('template')->default($self->for_module->meta->find_attribute_by_name('template')->default->());
}

## Definition

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
