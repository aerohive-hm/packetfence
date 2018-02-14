package pfappserver::Form::Config::PortalModule::Authentication::Choice;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::Choice

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Choice';
with 'pfappserver::Base::Form::Role::Help';
with 'pfappserver::Base::Form::Role::MultiSource';
with 'pfappserver::Base::Form::Role::WithSource';
with 'pfappserver::Base::Form::Role::WithCustomFields';

use captiveportal::DynamicRouting::Module::Authentication::Choice;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::Choice'}

## Definition

sub child_definition {
    my ($self) = @_;
    return ($self->source_fields, qw(custom_fields template));
}

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
