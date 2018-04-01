#!/usr/bin/perl

=head1 NAME

PathGenerator

=cut

=head1 DESCRIPTION

unit test for PathGenerator

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';
use pf::UnifiedApi::OpenAPI::Generator;
use pf::UnifiedApi::OpenAPI::Generator::Config;
use pf::UnifiedApi::Controller::Config::FloatingDevices;
use pf::UnifiedApi;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 5;

my $app = pf::UnifiedApi->new;

my $controller = pf::UnifiedApi::Controller::Config::FloatingDevices->new(app => $app);

my $generator = pf::UnifiedApi::OpenAPI::Generator->new;

is_deeply(
    $generator->generate_path($controller),
    {
        description => 'Configure floating devices',
    },
    "Simple generation"
);

my %getContent = standardGetContent();
my %putContent = standardGetContent();

delete $putContent{content}{"application/json"}{schema}{properties}{id};
$putContent{content}{"application/json"}{schema}{required} = [qw(pvid)];

sub standardGetContent {

    return (
        "content" => {
            "application/json" => {
                schema => {
                    properties => {
                        id => {
                            description => 'MAC Address',
                            type        => 'string'
                        },
                        ip => {
                            description => 'IP Address',
                            type        => 'string'
                        },
                        pvid => {
                            description =>
                              'VLAN in which PacketFence should put the port',
                            type => 'integer'
                        },
                        taggedVlan => {
                            description =>
'Comma separated list of VLANs. If the port is a multi-vlan, these are the VLANs that have to be tagged on the port.',
                            type => 'string'
                        },
                        trunkPort => {
                            description =>
                              'The port must be configured as a muti-vlan port',
                            type => 'string'
                        },
                    },
                    required => [qw(id pvid)],
                    type     => 'object',
                },
            }
        },
    );
}


{

    my $generator = pf::UnifiedApi::OpenAPI::Generator::Config->new;
    is_deeply(
        [
            $generator->operations(
                $controller,
                [
                    {
                        'operationId' => 'api.v1.Config::FloatingDevices.get',
                        'name'        => 'api.v1.Config::FloatingDevices.get',
                        'children'    => [],
                        'path' =>
                          '/config/floating_device/{floating_device_id}',
                        'depth' => 2,
                        'paths' =>
                          ['/config/floating_device/{floating_device_id}'],
                        'controller' => 'Config::FloatingDevices',
                        'path_type'  => 'resource',
                        'methods'    => ['GET'],
                        'path_part'  => '',
                        'action'     => 'get',
                        'full_path' =>
                          '/api/v1/config/floating_device/{floating_device_id}'
                    }
                ]
            )
        ],
        [
            get => {
                operationId => 'api.v1.Config::FloatingDevices.get',
                parameters => [],
                responses  => {
                    "200" => \%getContent,
                    "400" => {
                        "\$ref" => "#/components/responses/BadRequest",
                    },
                    "422" => {
                        "\$ref" => "#/components/responses/UnprocessableEntity"
                    }
                },
            },
        ],
        "Config Get"
    );
}

{

    my $generator = pf::UnifiedApi::OpenAPI::Generator::Config->new;
    is_deeply(
        [
            $generator->operations(
                $controller,
                [
                    {
                        'name'        => 'api.v1.Config::FloatingDevices.replace',
                        'children'    => [],
                        'path' =>
                          '/config/floating_device/{floating_device_id}',
                        'depth' => 2,
                        'paths' =>
                          ['/config/floating_device/{floating_device_id}'],
                        'controller' => 'Config::FloatingDevices',
                        'path_type'  => 'resource',
                        'methods'    => ['PUT'],
                        'path_part'  => '',
                        'action'     => 'replace',
                        'full_path' =>
                          '/api/v1/config/floating_device/{floating_device_id}'
                    }
                ]
            )
        ],
        [
            put => {
                parameters  => [],
                requestBody => \%putContent,
                responses   => {
                    "201" => {
                        "\$ref" => "#/components/responses/Created"
                    },
                    "400" => {
                        "\$ref" => "#/components/responses/BadRequest"
                    },
                    "422" => {
                        "\$ref" => "#/components/responses/UnprocessableEntity"
                    }
                },
            },
        ],
        "Config PUT"
    );
}
{

    my $generator = pf::UnifiedApi::OpenAPI::Generator::Config->new;
    is_deeply(
        [
            $generator->operations(
                $controller,
                [
                    {
                        'operationId' => 'api.v1.Config::FloatingDevices.remove',
                        'name'        => 'api.v1.Config::FloatingDevices.get',
                        'children'    => [],
                        'path' =>
                          '/config/floating_device/{floating_device_id}',
                        'depth' => 2,
                        'paths' =>
                          ['/config/floating_device/{floating_device_id}'],
                        'controller' => 'Config::FloatingDevices',
                        'path_type'  => 'resource',
                        'methods'    => ['DELETE'],
                        'path_part'  => '',
                        'action'     => 'remove',
                        'full_path' =>
                          '/api/v1/config/floating_device/{floating_device_id}'
                    }
                ]
            )
        ],
        [
            delete => {
                description => 'Deleted a config item',
                operationId => 'api.v1.Config::FloatingDevices.remove',
                parameters => [],
                responses  => {
                    "204" => {
                        description => 'Deleted a config item',
                    },
                },
            },
        ],
        "Config DELETE"
    );
}

#This test will running last
use Test::NoWarnings;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
