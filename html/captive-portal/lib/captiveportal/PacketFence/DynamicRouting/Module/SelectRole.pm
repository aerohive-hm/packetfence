package captiveportal::PacketFence::DynamicRouting::Module::SelectRole;

=head1 NAME

DynamicRouting::Module::SelectRole

=head1 DESCRIPTION

Module to select a new role for the device being registered

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module';

use List::MoreUtils qw(any);
use pf::nodecategory;

has 'template' => (is => 'rw', default => sub {'select-role.html'});

has 'admin_role' => (is => 'rw', required => 1);

has 'list_role' => (is => 'rw', required => 1);

=head2 execute_child

Select a new role for the device being registered

=cut

sub execute_child {
    my ($self) = @_;
    my @roles = split(' ',$self->admin_role);
    if(any { $_ eq $self->new_node_info->{category}} @roles) {
        if(my $new_role = $self->app->request->param('new_role')) {
            $self->new_node_info->{category} = $new_role;
            $self->done();
        }
        else {
            my @allowed_roles = split(' ',$self->list_role);
            $self->render($self->template, {
                title => $self->description,
                roles => [ grep { $_ ne $self->admin_role } @allowed_roles ],
            });
        }
    }
    else {
        $self->done();
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


