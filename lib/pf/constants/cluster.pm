package pf::constants::cluster;

=head1 NAME

pf::constants::cluster - constants for cluster object

=cut

=head1 DESCRIPTION

pf::constants::cluster

=cut

use strict;
use warnings;
use base qw(Exporter);

use pfconfig::constants;
use fingerbank::FilePath;
use pf::file_paths qw(
    $server_cert
    $server_key
    $server_pem
    $radius_server_key
    $radius_server_cert
    $radius_ca_cert
    $conf_dir
    $local_secret_file
);

our @EXPORT_OK = qw(@FILES_TO_SYNC);

our @FILES_TO_SYNC = (
    $server_cert, 
    $server_key, 
    $server_pem, 
    $radius_server_key,
    $radius_server_cert,
    $radius_ca_cert,
    $local_secret_file, 
    $pfconfig::constants::CONFIG_FILE_PATH, 
    "$conf_dir/iptables.conf", 
    $fingerbank::FilePath::CONF_FILE, 
    $fingerbank::FilePath::LOCAL_DB_FILE
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

