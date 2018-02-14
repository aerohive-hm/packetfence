package pfappserver::Form::Config::PortalModule::Root;

=head1 NAME

pfappserver::Form::Config::PortalModule:Root

=head1 DESCRIPTION

Form definition to create or update a root portal module.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule::Chained';
with 'pfappserver::Base::Form::Role::Help';

use captiveportal::DynamicRouting::Module::Root;
sub for_module {'captiveportal::PacketFence::DynamicRouting::Module::Root'}

## Definition

before 'setup' => sub {
    my ($self) = @_;
    $self->remove_field("actions");
};

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;


