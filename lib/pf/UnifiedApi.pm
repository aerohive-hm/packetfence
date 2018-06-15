package pf::UnifiedApi;

=head1 NAME

pf::UnifiedApi - The base of the mojo app

=cut

=head1 DESCRIPTION

pf::UnifiedApi

=cut

use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use pf::dal;
use pf::file_paths qw($log_conf_dir);
use MojoX::Log::Log4perl;
use pf::UnifiedApi::Controller;

has commands => sub {
  my $commands = Mojolicious::Commands->new(app => shift);
  Scalar::Util::weaken $commands->{app};
  unshift @{$commands->namespaces}, 'pf::UnifiedApi::Command';
  return $commands;
};

has log => sub {
    return MojoX::Log::Log4perl->new("$log_conf_dir/pfperl-api.conf",5 * 60);
};

=head2 startup

Setting up routes

=cut

our @API_V1_ROUTES = (
    {
        controller => 'Users',
        resource   => {
            children => [
                {
                    controller => 'Users::Nodes',
                    resource => {
                        children => [ 'Users::Nodes::Locationlogs' ],
                    }
                },
                {
                    controller => 'Users::Password',
                    resource => undef,
                    allow_singular => 1,
                    collection => {
                        http_methods => {
                            'get'    => 'get',
                            'delete' => 'remove',
                            'patch'  => 'update',
                            'put'    => 'replace',
                            'post'   => 'create'
                        }
                    },
                }
            ]
        },
    },
    {
        controller => 'Nodes',
        resource   => {
            subroutes => {
                (map { $_ => { post => $_ } } qw(register deregister)),
                fingerbank_info => {
                    get => 'fingerbank_info',
                }
            }
        },
        collection => {
            subroutes => {
                map { $_ => { post => $_ } } qw(bulk_register bulk_deregister search)
            }
        }
    },
    { controller => 'Tenants' },
    { controller => 'ApiUsers' },
    { controller => 'Locationlogs' },
    {
        controller => 'NodeCategories',
        collection => {
            http_methods => {
                'get'    => 'list',
            },
            subroutes => {
                map { $_ => { post => $_ } } qw(search)
            }
        },
        resource => {
            http_methods => {
                'get'    => 'get',
            },
        },
    },
    { 
        controller => 'Violations',
        collection => {
            subroutes    => {
                'by_mac/:search' => { get => 'by_mac' },                
                'search' => {
                    'post' => 'search'
                },
            },
        },      
    },
    {
        controller  => 'Reports',
        resource    => undef,
        collection => {
            http_methods => undef,
            subroutes => {
                map { $_ => { get => $_ } }
                  qw (
                  os
                  os_active
                  os_all
                  osclass_all
                  osclass_active
                  inactive_all
                  active_all
                  unregistered_all
                  unregistered_active
                  registered_all
                  registered_active
                  unknownprints_all
                  unknownprints_active
                  statics_all
                  statics_active
                  openviolations_all
                  openviolations_active
                  connectiontype
                  connectiontype_all
                  connectiontype_active
                  connectiontypereg_all
                  connectiontypereg_active
                  ssid
                  ssid_all
                  ssid_active
                  osclassbandwidth
                  osclassbandwidth_all
                  nodebandwidth
                  nodebandwidth_all
                  topsponsor_all
                  )
            },
        },
    },
    { controller => 'DhcpOption82s' },
    {
        controller  => 'Ip4logs',
        collection => {
            subroutes    => {
                'history/:search' => { get => 'history' },
                'archive/:search' => { get => 'archive' },
                'open/:search' => { get => 'open' }, 
                'search' => {
                    'post' => 'search'
                },
            },
        },
    },    
    { 
        controller => 'Services',
        resource   => {
            subroutes => {
                'status'  => { get => 'status' },
                'start'   => { post => 'start' },
                'stop'    => { post => 'stop' },
                'restart' => { post => 'restart' },
                'enable'  => { post => 'enable' },
                'disable' => { post => 'disable' },
            },
        },
        collection => {
            http_methods => {
                get => 'list',
            },
            subroutes => {
                'cluster_status' => { get => 'cluster_status' },
            },
        },
    },
    { controller => 'RadiusAuditLogs' },
    { 
        controller => 'Authentication',
        allow_singular => 1,
        collection => {
            subroutes    => {
                'admin_authentication' => { post => 'adminAuthentication' },
            },
        },      
    },
    qw(
        Config::AdminRoles
        Config::Bases
        Config::BillingTiers
        Config::ConnectionProfiles
        Config::DeviceRegistrations
        Config::Domains
        Config::Firewalls
        Config::FloatingDevices
        Config::MaintenanceTasks
        Config::PkiProviders
        Config::PortalModules
        Config::Realms
        Config::Roles
        Config::Scans
        Config::Sources
        Config::Switches
        Config::SwitchGroups
        Config::SyslogParsers
        Config::TrafficShapingPolicies
        Config::Violations
    ),
    {
        controller => 'Translations',
        collection => {
            http_methods => {
                get => "list",
            },
            subroutes => undef,
        },
        resource => {
            http_methods => {
                get => "get",
            },
            subroutes => undef,
        },
    },
);

sub startup {
    my ($self) = @_;
    $self->controller_class('pf::UnifiedApi::Controller');
    $self->routes->namespaces(['pf::UnifiedApi::Controller', 'pf::UnifiedApi']);
    $self->hook(before_dispatch => \&set_tenant_id);
    $self->plugin('pf::UnifiedApi::Plugin::RestCrud');
    $self->setup_api_v1_routes();
    $self->custom_startup_hook();
    $self->routes->any( '/*', sub {
        my ($c) = @_;
        return $c->unknown_action;
    });

    return;
}

sub setup_api_v1_routes {
    my ($self) = @_;
    my $r = $self->routes;
    my $api_v1_route = $r->any("/api/v1")->name("api.v1");
    foreach my $route ($self->api_v1_routes) {
        $api_v1_route->rest_routes($route);
    }
}

sub api_v1_routes {
    my ($self) = @_;
    return $self->api_v1_default_routes, $self->api_v1_custom_routes;
}

sub api_v1_default_routes {
    @API_V1_ROUTES
}

sub api_v1_custom_routes {

}

sub custom_startup_hook {

}

=head2 set_tenant_id

Set the tenant ID to the one specified in the header, or reset it to the default one if there is none

=cut

sub set_tenant_id {
    my ($c) = @_;
    my $tenant_id = $c->req->headers->header('X-PacketFence-Tenant-Id');
    if (defined $tenant_id) {
        unless (pf::dal->set_tenant($tenant_id)) {
            $c->render(json => { message => "Invalid tenant id provided $tenant_id"}, status => 404);
        }
    } else {
        pf::dal->reset_tenant();
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

