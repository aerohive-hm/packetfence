package captiveportal::PacketFence::DynamicRouting::Module::Message;

=head1 NAME

DynamicRouting::Module::Message

=head1 DESCRIPTION

Module to show a message to the user

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module';

has 'template' => (is => 'rw', default => sub {'message.html'});

has 'skipable' => (is => 'rw', default => sub {1});

has 'message' => (is => 'rw', required => 1);

=head2 execute_child

Display the message to the user and handle the continue if applicable

=cut

sub execute_child {
    my ($self) = @_;
    if($self->app->request->param('next') && $self->skipable){
        $self->done();
    }
    else {
        $self->render($self->template, {
            message => $self->message, 
            skipable => $self->skipable,
            title => $self->description,
        });
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

