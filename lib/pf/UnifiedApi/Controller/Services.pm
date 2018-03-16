package pf::UnifiedApi::Controller::Services;

=head1 NAME

pf::UnifiedApi::Controller::Services -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Services

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::RestRoute';
use pf::services;

sub resource {
    my ($self) = @_;

    my $service_id = $self->param('service_id');

    my $class = $self->_get_service_class($service_id);

    return 1 if defined($class);
    $self->render_error(404, { message => $self->status_to_error_msg(404) });
    return undef;
}


sub list {
    my ($self) = @_;
    $self->render(json => { items => [ map {$_->name} @pf::services::ALL_MANAGERS ] });
}

sub status {
    my ($self) = @_;
    my $service = $self->_get_service_class($self->param('service_id'));
    if ($service) {
        return $self->render(json => { 
            alive => $service->isAlive(),
            managed => $service->isManaged(),
            enabled => $service->isEnabled(),
            pid => $service->pid(), 
        });
    }
}

sub start {
    my ($self) = @_;
    my $service = $self->_get_service_class($self->param('service_id'));
    if ($service) {
        return $self->render(json => { start => $service->start(), pid => $service->pid() });
    }
}

sub stop {
    my ($self) = @_;
    my $service = $self->_get_service_class($self->param('service_id'));
    if ($service) {
        return $self->render(json => { stop => $service->stop() });
    }
}

sub restart {
    my ($self) = @_;
    my $service = $self->_get_service_class($self->param('service_id'));
    if ($service) {
        return $self->render(json => { restart => $service->restart(), pid => $service->pid() });
    }
}

sub enable {
    my ($self) = @_;
    my $service = $self->_get_service_class($self->param('service_id'));
    if ($service) {
        return $self->render(json => { enable => $service->sysdEnable() });
    }
}

sub disable {
    my ($self) = @_;
    my $service = $self->_get_service_class($self->param('service_id'));
    if ($service) {
        return $self->render(json => { disable => $service->sysdDisable() });
    }
}

sub _decode_service_id {
    my ($self, $service_id) = @_;
    $service_id =~ tr/-/_/; 
    $service_id =~ tr/\./_/;
    return $service_id;
}

sub _get_service_class {
    my ($self, $service_id) = @_;
    my $class = $pf::services::ALL_MANAGERS{$service_id};
    if(defined($class) && $class->can('new')){
        return $class;
    }
    else {
        $self->log->error("Unable to find a service manager by the name of $service_id");
        return undef;
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
