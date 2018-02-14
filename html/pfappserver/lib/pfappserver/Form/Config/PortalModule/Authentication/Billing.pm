package pfappserver::Form::Config::PortalModule::Authentication::Billing;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::Billing

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';

use captiveportal::DynamicRouting::Module::Authentication::Billing;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::Billing'}

has_field '+signup_template' => ( required => 0 );

# overriding to remove the signup template
sub child_definition {
    my ($self) = @_;
    return (qw(source_id custom_fields with_aup aup_template));
}

before 'setup' => sub {
    my ($self) = @_;
    $self->remove_field("actions");
};

## Definition

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
