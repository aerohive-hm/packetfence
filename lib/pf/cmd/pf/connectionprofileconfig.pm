package pf::cmd::pf::connectionprofileconfig;
=head1 NAME

pf::cmd::pf::connectionprofileconfig add documentation

=head1 SYNOPSIS

pfcmd connectionprofileconfig get <all|default|ID>

pfcmd connectionprofileconfig add <ID> [assignments]

pfcmd connectionprofileconfig edit <ID> [assignments]

pfcmd connectionprofileconfig delete <ID>

pfcmd connectionprofileconfig clone <TO_ID> <FROM_ID> [assignments]

query/modify profiles.conf configuration file

=head1 DESCRIPTION

pf::cmd::pf::connectionprofileconfig

=cut

use strict;
use warnings;
use base qw(pf::base::cmd::config_store);
use pf::ConfigStore::Profile;

sub configStoreName { "pf::ConfigStore::Profile" }

sub display_fields { qw(id description logo redirecturl always_use_redirecturl locale) }

sub idKey { 'id' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

