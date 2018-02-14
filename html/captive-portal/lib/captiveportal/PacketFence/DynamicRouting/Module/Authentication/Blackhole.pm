package captiveportal::PacketFence::DynamicRouting::Module::Authentication::Blackhole;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::Blackhole

=head1 DESCRIPTION

Blackhole authentication module (denies any access)

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication';
with 'captiveportal::Role::FieldValidation';

has '+source' => (isa => 'pf::Authentication::Source::BlackholeSource');

=head2 execute_child

Execute the module

=cut

sub execute_child {
    my ($self) = @_;

    $self->render("message.html", {
        message => "register: not allowed to register", 
        title => $self->description,
    });
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

