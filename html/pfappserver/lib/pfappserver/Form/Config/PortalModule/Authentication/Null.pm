package pfappserver::Form::Config::PortalModule::Authentication::Null;

=head1 NAME

pfappserver::Form::Config::PortalModule::Authentcation::Null

=head1 DESCRIPTION

Form definition to create or update an authentication portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Authentication';

use captiveportal::DynamicRouting::Module::Authentication::Null;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Authentication::Null'}

before 'setup' => sub {
    my ($self) = @_;
    $self->remove_field("pid_field");
};

## Definition

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
