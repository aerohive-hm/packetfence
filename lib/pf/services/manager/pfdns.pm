package pf::services::manager::pfdns;
=head1 NAME

pf::services::manager::pfdns

=cut

=head1 DESCRIPTION

pf::services::manager::pfdns

=cut

use strict;
use warnings;
use Moo;
use Template;
use NetAddr::IP;

use pf::cluster;
use pf::config qw(
    %Config
    %ConfigNetworks
);

use pf::file_paths qw(
    $conf_dir
    $install_dir
    $var_dir
    $generated_conf_dir
);

use pf::util;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfdns' } );

tie our %domain_dns_servers, 'pfconfig::cached_hash', 'resource::domain_dns_servers';

=head2 generateConfig

Generate the configuration file

=cut

sub generateConfig {
    my ($self,$quick) = @_;
    my $tt = Template->new(ABSOLUTE => 1);
    my %tags;

    foreach my $key ( keys %domain_dns_servers ) {
        my $dns = join ' ',@{$domain_dns_servers{$key}};
        $tags{'domain'} .= <<"EOT";
    proxy $key. $dns
EOT
    }

    foreach my $network ( keys %ConfigNetworks ) {
        # We skip non-inline networks/interfaces
        next if ( !pf::config::is_network_type_inline($network) );
        my $net_addr = NetAddr::IP->new($network,$ConfigNetworks{$network}{'netmask'});
        my $cidr = $net_addr->cidr();
        $tags{'inline'} .= <<"EOT";
    proxy $cidr . $ConfigNetworks{$network}{'dns'}
EOT
    }
    $tt->process("$conf_dir/pfdns.conf", \%tags, "$generated_conf_dir/pfdns.conf") or die $tt->error();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
