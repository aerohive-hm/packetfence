package pf::services::manager::httpd_proxy;

=head1 NAME

pf::services::manager::httpd_proxy add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_proxy

=cut

use strict;
use warnings;
use Moo;
use pf::config qw(%Config @internal_nets);
use pf::util;

extends 'pf::services::manager::httpd';

has '+name' => (default => sub { 'httpd.proxy' } );

sub isManaged {
    my ($self) = @_;
    return  isenabled($Config{'fencing'}{'interception_proxy'}) && $self->SUPER::isManaged();
}

sub additionalVars {
    my ($self) = @_;
    my %vars = (
        proxy_ports => [split(/ *, */,$Config{'fencing'}{'interception_proxy_port'})],
    );
    return %vars;
}

sub port { 444 }

sub vhosts {
    return [map {
        (defined $_->{Tvip} && $_->{Tvip} ne '') ?  $_->{Tvip} : $_->{Tip}
    } @internal_nets];
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
