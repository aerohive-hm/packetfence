package pf::WebAPI::InitCollectorHandler;

=head1 NAME

pf::WebAPI::InitCollectorHandler

=cut

=head1 DESCRIPTION

pf::WebAPI::InitCollectorHandler

=cut

use strict;
use warnings;

use Apache2::RequestRec ();
use pf::log;
use pf::Redis;
use JSON::MaybeXS;

use Apache2::Const -compile => 'OK';

sub handler {
    my $r = shift;
    return Apache2::Const::OK;
}

=head2 child_init

Initialize the child process
Reestablish connections to global connections
Refresh any configurations

=cut

sub child_init {
    my ($class, $child_pool, $s) = @_;
    my $redis = pf::Redis->new(server => '127.0.0.1:6379');
    #Avoid child processes having the same random seed
    srand();
    return Apache2::Const::OK;
}

=head2 post_config

Cleaning before forking child processes
Close connections to avoid any sharing of sockets

=cut

sub post_config {
    my ($class, $conf_pool, $log_pool, $temp_pool, $s) = @_;
    return Apache2::Const::OK;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

