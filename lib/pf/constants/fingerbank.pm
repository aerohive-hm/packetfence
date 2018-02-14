package pf::constants::fingerbank;

=head1 NAME

pf::constants::fingerbank - constants for fingerbank

=cut

=head1 DESCRIPTION

pf::constants::fingerbank

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw($RATE_LIMIT);

=head2 $RATE_LIMIT

The amount of seconds between each fingerbank process based on the query parameters

=cut

Readonly our $RATE_LIMIT => 60;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


