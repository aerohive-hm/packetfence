package pf::services::manager::httpd_graphite;

=head1 NAME

pf::services::manager::httpd_graphite

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_graphite

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw(
    $conf_dir
    $install_dir
);
use pf::config qw(
    %Config
    $management_network
    $OS
);
use pf::util;
use pf::cluster;
use pf::log;
use Bytes::Random::Secure qw( random_bytes_base64 );

extends 'pf::services::manager::httpd';

has '+name' => ( default => sub {'httpd.graphite'} );

has '+optional' => ( default => sub {1} );

my $SECRET_FILE = $conf_dir . '/monitoring/graphite_secret';

sub generateConfig {
    my ($self) = @_;
    $self->SUPER::generateConfig();
    generate_local_settings();
    generate_dashboard_settings();
}

sub vhosts { [ "0.0.0.0" ] }
sub port { 9000 }

sub generate_local_settings {
    my %tags;
    $tags{'template'} = "$conf_dir/monitoring/local_settings.py.$OS";
    $tags{'conf_dir'} = "$install_dir/var/conf";
    $tags{'log_dir'}  = "$install_dir/logs";
    $tags{'install_dir'}   = "$install_dir";
    $tags{'management_ip'}
        = defined( $management_network->tag('vip') )
        ? $management_network->tag('vip')
        : $management_network->tag('ip');

    $tags{'secret'}               = generate_secret();
    $tags{'graphite_host'}        = "$Config{'graphite'}{'graphite_host'}";
    $tags{'graphite_port'}        = "$Config{'graphite'}{'graphite_port'}";
    $tags{'db_graphite_database'} = $Config{'database'}{'db'} . "_graphite";
    $tags{'db_host'}              = $Config{'graphite'}{'db_host'} || $Config{'database'}{'host'};
    $tags{'db_port'}              = $Config{'graphite'}{'db_port'} || $Config{'database'}{'port'};
    $tags{'db_user'}              = $Config{'graphite'}{'db_user'} || $Config{'database'}{'user'};
    $tags{'db_password'}          = $Config{'graphite'}{'db_pass'} || $Config{'database'}{'pass'};
    $tags{'carbon_hosts'} = get_cluster_destinations()
      // '"' . $tags{'graphite_host'} . ":9000" . '"';

    parse_template( \%tags, "$tags{'template'}", "$install_dir/var/conf/local_settings.py" );
}

sub generate_dashboard_settings {
    my %tags;
    $tags{'template'} = "$conf_dir/monitoring/dashboard.conf";

    parse_template( \%tags, "$tags{'template'}", "$install_dir/var/conf/dashboard.conf" );
}

sub get_cluster_destinations {
    my $carbon_hosts_string;
    my @carbon_urls;
    if ( @cluster_servers > 1 ) {
        for (@cluster_servers) {
            push( @carbon_urls, '"' . $_->{management_ip} . ":9000" . '"' );
        }
        $carbon_hosts_string = join( ',', @carbon_urls );
    }
    return $carbon_hosts_string;
}

sub generate_secret {
    my $logger = get_logger();
    use File::Slurp;
    my $secret;
    if ( -e $SECRET_FILE ) {
        $secret = read_file( $SECRET_FILE );
        unless ( defined $secret ) {
            $logger->error( "unable to read graphite secret file " . $SECRET_FILE );
        }
        chomp $secret;
    }
    else {
        $secret = random_bytes_base64(26);
        chomp $secret;
        open( my $fh, ">", $SECRET_FILE );
        print $fh $secret;
    }

    return $secret;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
