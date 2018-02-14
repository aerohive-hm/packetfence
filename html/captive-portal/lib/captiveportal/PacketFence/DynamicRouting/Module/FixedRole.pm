package captiveportal::PacketFence::DynamicRouting::Module::FixedRole;

=head1 NAME

DynamicRouting::Module::FixedRole

=head1 DESCRIPTION

Module to keep the latest role assigned to a device if this role is in the list.

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module';

use List::MoreUtils qw(any);
use pf::node;

has 'stone_roles' => (is => 'rw', required => 1);

=head2 execute_child

Use the old role if it match in the list for the device being registered

=cut

sub execute_child {
    my ($self) = @_;
    my $node_info = node_view($self->node_info->{mac});
    my @roles = split(' ',$self->stone_roles);
    if(any { $_ eq $node_info->{category}} @roles) {
        $self->new_node_info->{category} = $node_info->{category};
        $self->done();
    } else {
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


