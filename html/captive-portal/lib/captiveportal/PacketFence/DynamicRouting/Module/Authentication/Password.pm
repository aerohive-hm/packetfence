package captiveportal::PacketFence::DynamicRouting::Module::Authentication::Password;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::Password

=head1 DESCRIPTION

Login Controller with a predefined username for captiveportal

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::Login';
with 'captiveportal::Role::FieldValidation';
with 'captiveportal::Role::MultiSource';

has '+username' => (is => 'rw');

=head2 _build_required_fields

Build the required fields based on the PID field, the custom fields and the mandatory fields of the source

=cut

sub _build_required_fields {
    my ($self) = @_;
    my @fields = ((grep {$_ ne 'username' && $_ ne 'password' } @{$self->SUPER::_build_required_fields()}), "password");

    return \@fields;
}

=head2 execute_child

Execute this module

=cut

sub execute_child {
    my ($self) = @_;
    if($self->app->request->method eq "POST"){
        if($self->app->request->path eq "challenge") {
            if( defined $self->challenge_data){
                $self->challenge();
            }
            else {
                $self->prompt_fields();
            }
        } else {
            $self->authenticate($self->username);
        }
    }
    else {
        if( defined $self->challenge_data){
            $self->display_challenge();
        }
        else {
            $self->prompt_fields();
        }
    }
};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
