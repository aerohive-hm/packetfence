package pf::api::local;

=head1 NAME

pf::api::local local client for pf::api

=cut

=head1 DESCRIPTION

pf::api::local

local client for pf::api which calls the api calls directly
To avoid circular dependencies pf::api needs to be included before consuming this module

=cut

use strict;
use warnings;
use Moo;


=head2 call

calls the pf api

=cut

sub call {
    my ($self,$method,@args) = @_;
    return pf::api->$method(@args);
}

=head2 notify

calls the pf api ignoring the return value

=cut

sub notify {
    my ($self,$method,@args) = @_;
    eval {
        pf::api->$method(@args);
    };
    return;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

