package pf::constants::scan;

=head1 NAME

pf::constants::scan - constants for scan object

=cut

=head1 DESCRIPTION

pf::constants::scan

=cut

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
  $SCAN_VID
  $POST_SCAN_VID
  $PRE_SCAN_VID
  $SEVERITY_HOLE
  $SEVERITY_WARNING
  $SEVERITY_INFO
  $STATUS_NEW
  $STATUS_STARTED
  $STATUS_CLOSED
  $WMI_NS_ERR
);

use Readonly;

Readonly our $SCAN_VID => '1200001';
Readonly our $POST_SCAN_VID => '1200004';
Readonly our $PRE_SCAN_VID => '1200005';
Readonly our $SEVERITY_HOLE     => 1;
Readonly our $SEVERITY_WARNING  => 2;
Readonly our $SEVERITY_INFO     => 3;
Readonly our $STATUS_NEW => 'new';
Readonly our $STATUS_STARTED => 'started';
Readonly our $STATUS_CLOSED => 'closed';
Readonly our $WMI_NS_ERR => '0x80041010';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

