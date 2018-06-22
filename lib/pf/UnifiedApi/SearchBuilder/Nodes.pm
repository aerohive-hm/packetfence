package pf::UnifiedApi::SearchBuilder::Nodes;

=head1 NAME

pf::UnifiedApi::SearchBuilder::Nodes -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::SearchBuilder::Nodes

=cut

use strict;
use warnings;
use Moo;
extends qw(pf::UnifiedApi::SearchBuilder);
use pf::dal::node;
use pf::constants qw($ZERO_DATE);

our @LOCATION_LOG_JOIN = (
    "=>{locationlog.mac=node.mac,node.tenant_id=locationlog.tenant_id,locationlog.end_time='$ZERO_DATE'}",
    'locationlog',
    {
        operator  => '=>',
        condition => {
            'node.mac'       => { '=' => { -ident => '%2$s.mac' } },
            'node.tenant_id' => { '=' => { -ident => '%2$s.tenant_id' } },
            'locationlog2.end_time' => $ZERO_DATE,
            -or                     => [
                '%1$s.start_time' => { '<' => { -ident => '%2$s.start_time' } },
                '%1$s.start_time' => undef,
                -and              => [
                    '%1$s.start_time' =>
                      { '=' => { -ident => '%2$s.start_time' } },
                    '%1$s.id' => { '<' => { -ident => '%2$s.id' } },
                ],
            ],
        },
    },
    'locationlog|locationlog2',
);

our @IP4LOG_JOIN = (
    {
        operator  => '=>',
        condition => {
            'ip4log.ip' => {
                "=" => \
"( SELECT `ip` FROM `ip4log` WHERE `mac` = `node`.`mac` AND `tenant_id` = `node`.`tenant_id`  ORDER BY `start_time` DESC LIMIT 1 )",
            }
        }
    },
    'ip4log',
);

our %ALLOWED_JOIN_FIELDS = (
    'ip4log.ip' => {
        join_spec => \@IP4LOG_JOIN,
    },
    (
        map {
            (
                "locationlog.$_" => {
                    join_spec => \@LOCATION_LOG_JOIN,
                }
            )
          } qw(
          switch port vlan
          role connection_type connection_sub_type
          dot1x_username ssid start_time
          end_time switch_ip switch_mac
          stripped_user_name realm session_id
          ifDesc
          )
      )
);

sub allowed_join_fields {
    \%ALLOWED_JOIN_FIELDS
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

