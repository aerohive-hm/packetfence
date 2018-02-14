package pf::WebAPI::InitHandler::Admin;

=head1 NAME

pf::WebAPI::InitHandler::Admin

=cut

=head1 DESCRIPTION

pf::WebAPI::InitHandler::Admin

=cut

use strict;
use warnings;

use pf::SwitchFactory();

use base qw(pf::WebAPI::InitHandler);
use Apache2::Const -compile => 'OK';
use pf::db;

=head2 post_config_hook

Cleaning before forking child processes
Close connections to avoid any sharing of sockets

=cut

sub post_config_hook {
    my ($class, $conf_pool, $log_pool, $temp_pool, $s) = @_;
    db_set_max_statement_timeout(600); # Set the database statement timeout
    return Apache2::Const::OK;
}

=head2 preloadSwitches

Preload all the switches

=cut

sub preloadSwitches {
    pf::SwitchFactory->preloadAllModules();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

