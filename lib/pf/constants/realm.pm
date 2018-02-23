package pf::constants::realm;

=head1 NAME

pf::constants::realm

=cut

=head1 DESCRIPTION

Constants class for realms

=cut

use strict;
use warnings;

our $DEFAULT = "DEFAULT";

our $LOCAL = "LOCAL";

our $NULL = "NULL";

our $NO_CONTEXT = "none";

our $PORTAL_CONTEXT = "portal";

our $ADMIN_CONTEXT = "admin";

our $RADIUS_CONTEXT = "radius";

our @CONTEXTS = (
    $PORTAL_CONTEXT,
    $ADMIN_CONTEXT,
    $RADIUS_CONTEXT,
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

