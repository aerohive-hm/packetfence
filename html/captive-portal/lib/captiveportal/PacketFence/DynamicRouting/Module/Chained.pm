package captiveportal::PacketFence::DynamicRouting::Module::Chained;

=head1 NAME

captiveportal::DynamicRouting::Module::Chained

=head1 DESCRIPTION

To chain multiple modules one after the other

=cut

use Moose;
extends 'captiveportal::DynamicRouting::ModuleManager';

use pf::log;

has 'current_module_index' => (is => 'rw', builder => '_build_current_module_index', lazy => 1);

=head2 _build_current_module_index

Builder for the current module index inside the modules_order array

=cut

sub _build_current_module_index {
    my ($self) = @_;
    return $self->session->{current_module_index} // 0;
}

=head2 after current_module_index

Update the current_module_index in the session after setting it

=cut

after 'current_module_index' => sub {
    my ($self) = @_;
    $self->session->{current_module_index} = $self->{current_module_index};  
};

=head2 next

Continue onto the next child module
If we have completed all the modules in modules_order, we have completed this module

=cut

sub next {
    my ($self) = @_;
    $self->current_module_index($self->current_module_index + 1);
    get_logger->debug("Executing module ".$self->current_module_index."/".$self->count_modules);
    if($self->current_module_index >= $self->count_modules){
        $self->done();
    }
    else {
        $self->current_module($self->get_module($self->current_module_index)->id);
        $self->redirect_root();
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

