package captiveportal::PacketFence::DynamicRouting::Module::Choice;

=head1 NAME

captiveportal::DynamicRouting::Module::Choice

=head1 DESCRIPTION

For giving a choice between multiple modules

=cut

use Moose;
extends 'captiveportal::DynamicRouting::ModuleManager';

use pf::util;
use pf::log;

has 'show_first_module_on_default' => (is => 'rw', isa => 'Str', default => sub{'disabled'});

has 'template' => (is => 'rw', isa => 'Str', default => sub {'content-with-choice.html'});

=head2 next

Once we complete one of the child modules, this module is done

=cut

sub next {
    my ($self) = @_;
    $self->done();
}

=head2 before execute_child

Allow to switch from one of the choice to another via the /switchto/MODULE_ID path

=cut

before 'execute_child' => sub {
    my ($self) = @_;
    if($self->app->request->path =~ /^switchto\/(.+)/){
        $self->current_module($1) if($self->module_map->{$1});
    }
};

=head2 render

Override normal behavior to render with a menu

=cut

sub render {
    my ($self, @params) = @_;
    my $inner_content = $self->app->_render(@params);
    $self->render_choice($inner_content);
}

=head2 render_choice

Render the template surrounded by choices to switch between the different available modules

=cut

sub render_choice {
    my ($self, $inner_content) = @_;
    my $args = {content => $inner_content, modules => [$self->available_choices], mod_manager_current_module => $self->current_module};

    $self->SUPER::render($self->template, $args);
}

=head2 available_choices

The choices that should be given to the user depending on whether or not the child module wants to be displayed

=cut

sub available_choices {
    my ($self) = @_;
    return grep {$_->display} $self->all_modules;
}

=head2 default_behavior

Define what should be the default behavior
The show_first_module_on_default will determine if a default choice is selected for the user

=cut

sub default_behavior {
    my ($self) = @_;
    if(isenabled($self->show_first_module_on_default)){
        get_logger->debug("Default behavior is to show the first module");
        $self->default_module->execute();
    }
    elsif($self->available_choices == 1){
        get_logger->debug("The choice is between one module. Selecting it automatically");
        $self->default_module->execute();
    }
    else {
        get_logger->debug("Default behavior is to show only the choice");
        $self->render_choice(); 
    }
}

=head2 default_module

The default module

=cut

sub default_module {
    my ($self) = @_;
    return [$self->available_choices]->[0];
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

