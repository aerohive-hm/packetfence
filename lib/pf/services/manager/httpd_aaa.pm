package pf::services::manager::httpd_aaa;

=head1 NAME

pf::services::manager::httpd_aaa

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_aaa

=cut

use strict;
use warnings;
use Moo;
use pf::config qw(%Config $OS);
use pf::file_paths qw(
    $install_dir
);

extends 'pf::services::manager::httpd_webservices';

has '+name' => ( default => sub {'httpd.aaa'} );

sub port {
    return $Config{ports}{aaa};
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
