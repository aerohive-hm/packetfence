package pf::WebAPI::InitHandler;
=head1 NAME

pf::WebAPI::InitHandler

=cut

=head1 DESCRIPTION

pf::WebAPI::InitHandler

=cut

use strict;
use warnings;

use Apache2::RequestRec ();
use pf::StatsD qw($statsd);
use pf::db;
use pf::CHI;
use pf::CHI::Request;
use pf::SwitchFactory();
use pf::dal;
use pf::constants qw($DEFAULT_TENANT_ID);

use Apache2::Const -compile => 'OK';

sub handler {
    my $r = shift;
    pf::CHI::Request::clear_all();
    pf::dal->reset_tenant();
    return Apache2::Const::OK;
}

=head2 child_init

Initialize the child process
Reestablish connections to global connections
Refresh any configurations

=cut

sub child_init {
    my ($class, $child_pool, $s) = @_;
    #Avoid child processes having the same random seed
    srand();
    pf::StatsD->initStatsd;
    #The database initialization can fail on the initial install
    eval {
        db_connect();
    };
    return Apache2::Const::OK;
}

=head2 post_config

Cleaning before forking child processes
Close connections to avoid any sharing of sockets

=cut

sub post_config {
    my ($class, $conf_pool, $log_pool, $temp_pool, $s) = @_;
    pf::StatsD->closeStatsd;
    db_disconnect();
    $class->preloadSwitches();
    pf::CHI->clear_memoized_cache_objects;
    $class->post_config_hook();
    return Apache2::Const::OK;
}

=head2 preloadSwitches

Preload switches in the post_config

=cut

sub preloadSwitches {
    my ($class) = @_;
    pf::SwitchFactory->preloadConfiguredModules();
}

=head2 post_config_hook

post config hook allow child class to add additional actions

=cut

sub post_config_hook { }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

