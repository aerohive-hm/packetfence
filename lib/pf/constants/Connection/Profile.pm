package pf::constants::Connection::Profile;

=head1 NAME

pf::constants::Connection::Profile - constants for Connection::Profile object

=cut

=head1 DESCRIPTION

pf::constants::Connection::Profile

=cut

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
    $BLOCK_INTERVAL_DEFAULT_VALUE
    $DEFAULT_PROFILE
    $MATCH_STYLE_ALL
    $DEFAULT_ROOT_MODULE
    $PENDING_POLICY
);

our $BLOCK_INTERVAL_DEFAULT_VALUE = '10m';
our $DEFAULT_PROFILE = 'default';
our $MATCH_STYLE_ALL = 'all';
our $DEFAULT_ROOT_MODULE = "default_policy";
our $PENDING_POLICY = "default_pending_policy";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

