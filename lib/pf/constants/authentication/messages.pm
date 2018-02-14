package pf::constants::authentication::messages;

=head1 NAME

pf::constants::authentication::messages - constants for authentication object result messages

=cut

=head1 DESCRIPTION

pf::constants::authentication::messages

=cut

use strict;
use warnings;
use Readonly;
use base qw(Exporter);
our @EXPORT = qw(
  $COMMUNICATION_ERROR_MSG $AUTH_FAIL_MSG $AUTH_SUCCESS_MSG $INVALID_EMAIL_MSG $LOCALDOMAIN_EMAIL_UNAUTHORIZED
);

Readonly our $COMMUNICATION_ERROR_MSG => 'Unable to validate credentials at the moment';
Readonly our $AUTH_FAIL_MSG => 'Invalid login or password';
Readonly our $AUTH_SUCCESS_MSG => 'Authentication successful.';
Readonly our $INVALID_EMAIL_MSG => 'Invalid e-mail address';
Readonly our $LOCALDOMAIN_EMAIL_UNAUTHORIZED => "You can't register as a guest with this corporate email address. Please register as a regular user using your email address instead.";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

