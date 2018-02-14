package pf::constants::user;

=head1 NAME

pf::constants::user -

=cut

=head1 DESCRIPTION

pf::constants::user

=cut

use strict;
use warnings;

our ($PF_UID, $PF_GID);
our $PF_ID = 'pf';
our $PF_GROUP = 'pf';

( undef, undef, $PF_UID, $PF_GID ) = getpwnam($PF_ID);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

