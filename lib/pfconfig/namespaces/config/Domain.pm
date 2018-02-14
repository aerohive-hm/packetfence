package pfconfig::namespaces::config::Domain;

=head1 NAME

pfconfig::namespaces::config::Domain

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Domain

This module creates the configuration hash associated to domain.conf

=cut


use strict;
use warnings;

use pfconfig::namespaces::config;
use Data::Dumper;
use pf::log;
use pf::file_paths qw($domain_config_file);
use Sys::Hostname;

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $domain_config_file;
    $self->{child_resources} = [ 'resource::domain_dns_servers' ];
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{$self->{cfg}};

    # Inflate %h to the host machine name
    # This is done since Samba 4+ doesn't inflate it itself anymore
    while(my ($id, $cfg) = each(%tmp_cfg)){
        if(lc($cfg->{server_name}) eq "%h") {
            $cfg->{server_name} = [split(/\./,hostname())]->[0];
        }
    }

    $self->{cfg} = \%tmp_cfg;

    return \%tmp_cfg;

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

