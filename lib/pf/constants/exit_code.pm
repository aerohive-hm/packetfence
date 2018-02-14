package pf::constants::exit_code;
=head1 NAME

pf::constants::exit_code

=cut

=head1 DESCRIPTION

pf::constants::exit_code

Constants for all exit code for packect fence

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;
our @EXPORT_OK = qw($EXIT_SUCCESS $EXIT_FAILURE $EXIT_SERVICES_NOT_STARTED $EXIT_FATAL);

=head1 EXIT CODES

=head2 $EXIT_SUCCESS

Success

=cut

Readonly::Scalar our $EXIT_SUCCESS => 0;

=head2 $EXIT_FAILURE

General failure

=cut

Readonly::Scalar our $EXIT_FAILURE => 1;

=head2 $EXIT_FAILURE

General failure

=cut

Readonly::Scalar our $EXIT_SERVICES_NOT_STARTED => 3;

=head2 $EXIT_FATAL

fatal error

=cut

Readonly::Scalar our $EXIT_FATAL => 255;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

