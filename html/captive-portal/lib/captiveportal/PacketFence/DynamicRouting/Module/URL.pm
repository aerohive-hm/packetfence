package captiveportal::PacketFence::DynamicRouting::Module::URL;

=head1 NAME

DynamicRouting::Module::URL

=head1 DESCRIPTION

Module to redirect a user to a URL

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module';

has 'url' => (is => 'rw', required => 1);

has 'skipable' => (is => 'rw', default => sub {1});

=head2 execute_child

Redirect the user to the URL and handle the continue if applicable

=cut

sub execute_child {
    my ($self) = @_;
    if($self->app->request->param('next') && $self->skipable){
        $self->done();
    }
    else {
        $self->app->redirect($self->url);
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

