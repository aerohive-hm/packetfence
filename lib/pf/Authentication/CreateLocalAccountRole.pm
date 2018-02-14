package pf::Authentication::CreateLocalAccountRole;

=head1 NAME

pf::Authentication::CreateLocalAccountRole

=head1 DESCRIPTION

Role that defines the Authentication source behavior for creating local accounts

=cut

use Moose::Role;
use pf::Authentication::constants qw($LOCAL_ACCOUNT_UNLIMITED_LOGINS);

has 'create_local_account' => (isa => 'Str', is => 'rw', default => 'no');
has 'local_account_logins' => (isa => 'Str', is => 'rw', default => $LOCAL_ACCOUNT_UNLIMITED_LOGINS);

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
