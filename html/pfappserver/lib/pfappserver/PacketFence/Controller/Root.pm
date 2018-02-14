package pfappserver::PacketFence::Controller::Root;

=head1 NAME

pfappserver::PacketFence::Controller::Root - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use pf::db;
use pf::config qw(%Config);
use pf::util;
BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');


=head1 METHODS

=over


=head2 auto

auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    $c->stash->{readonly_mode} = db_check_readonly();
    return 1;
}

=item index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $installation_type = $c->model('Configurator')->checkForUpgrade();
    if ($installation_type ne $pfappserver::Model::Configurator::INSTALLATION) {
        # Redirect to the admin interface
        my $admin_url = $c->uri_for($c->controller('Admin')->action_for('index'));
        $c->log->info("Redirecting to admin interface $admin_url");
        $c->response->redirect($admin_url);
    } else {
        # Redirect to the configurator
        $c->response->redirect($c->uri_for($c->controller('Configurator')->action_for('index')));
    }
    $c->detach();
}

=item default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=item end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
     
    if (isenabled($Config{'advanced'}{'admin_csp_security_headers'})) {
        $c->csp_server_headers();
    }
  
    if (defined($c->req->header('accept')) && $c->req->header('accept') eq 'application/json'){
        $c->stash->{current_view} = 'JSON';
    }
    if (scalar @{$c->error}) {
        for my $error ( @{ $c->error } ) {
            $c->log->error($error);
        }
        $c->stash->{status_msg} = $c->pf_localize('An error condition has occured. See server side logs for details.');
        $c->response->status(500);
        $c->clear_errors;
    }
    elsif (exists $c->stash->{status_msg} && defined $c->stash->{status_msg} ) {
        $c->stash->{status_msg} = $c->pf_localize($c->stash->{status_msg});
    }
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
