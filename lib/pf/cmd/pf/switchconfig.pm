package pf::cmd::pf::switchconfig;
=head1 NAME

pf::cmd::pf::switchconfig add documentation

=head1 SYNOPSIS

pfcmd switchconfig get <all|default|ID>

pfcmd switchconfig add <ID> [assignments]

pfcmd switchconfig edit <ID> [assignments]

pfcmd switchconfig delete <ID>

pfcmd switchconfig clone <TO_ID> <FROM_ID> [assignments]

query/modify switches configuration file

=head1 DESCRIPTION

pf::cmd::pf::switchconfig

=cut

use strict;
use warnings;
use pf::log;
use pf::ConfigStore::Switch;
use base qw(pf::base::cmd::config_store);

sub configStoreName { "pf::ConfigStore::Switch" }

sub display_fields {
    qw(id ip type mode inlineTrigger VoIPEnabled vlans normalVlan
      registrationVlan isolationVlan macDetectionVlan guestVlan voiceVlan inlineVlan customVlan1 customVlan2 customVlan3 customVlan4 customVlan5
      uplink deauthMethod cliTransport cliUser cliPwd cliEnablePwd wsTransport wsUser wsPwd SNMPVersionTrap SNMPCommunityTrap
      SNMPUserNameTrap SNMPAuthProtocolTrap SNMPAuthPasswordTrap SNMPPrivProtocolTrap SNMPPrivPasswordTrap SNMPVersion
      SNMPCommunityRead SNMPCommunityWrite SNMPEngineID SNMPUserNameRead SNMPAuthProtocolRead SNMPAuthPasswordRead
      SNMPPrivProtocolRead SNMPPrivPasswordRead SNMPUserNameWrite SNMPAuthProtocolWrite SNMPAuthPasswordWrite
      SNMPPrivProtocolWrite SNMPPrivPasswordWrite radiusSecret controllerIp roles macSearchesMaxNb macSearchesSleepInterval)
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

