package captiveportal::Role::Routed;

=head1 NAME

captiveportal::Role::Routed

=head1 DESCRIPTION

Routing role to apply on a module

=cut

use Moose::Role;
use pf::log;

has 'route_map' => (is => 'rw', default => sub{ {} });

=head2 around execute_child

Route to the appropriate method if necessary

=cut

around 'execute_child' => sub {
    my $orig = shift;
    my $self = shift;

    my $method = $self->path_method('/'.$self->app->request->path());
    if(defined($method)){
        $method->($self);
    }
    else {
        $self->$orig();
    }
};

=head2 path_method

Get the method associated to a path if it exists

=cut

sub path_method {
    my ($self, $path) = @_;
    foreach my $regex (keys %{$self->route_map}){
        get_logger->debug("Checking if $path matches $regex");
        if($path =~ /^$regex$/){
            get_logger->debug("Found a route match : $regex");
            return $self->route_map->{$regex};
        }
    }
    return undef;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

