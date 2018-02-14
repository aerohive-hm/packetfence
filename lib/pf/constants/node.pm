package pf::constants::node;

=head1 NAME

pf::constants::node - constants for node

=cut

=head1 DESCRIPTION

pf::constants::node

constants for node

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw(
    $STATUS_REGISTERED
    $STATUS_UNREGISTERED
    $STATUS_PENDING
    %ALLOW_STATUS
    $NODE_DISCOVERED_TRIGGER_DELAY
);
Readonly::Scalar our $STATUS_REGISTERED => 'reg';
Readonly::Scalar our $STATUS_UNREGISTERED => 'unreg';
Readonly::Scalar our $STATUS_PENDING => 'pending';
Readonly::Scalar our $NODE_DISCOVERED_TRIGGER_DELAY => 10000;

Readonly::Hash our %ALLOW_STATUS => (
    $STATUS_REGISTERED   => 1,
    $STATUS_UNREGISTERED => 1,
    $STATUS_PENDING      => 1,
);
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

