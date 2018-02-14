package pfappserver::Model::Admin;

=head1 NAME

pfappserver::Model::Admin - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use pf::file_paths qw($conf_dir);
use pf::log;

=head1 METHODS


=head2 pf_release

Returns the content of conf/pf-release

=cut

sub pf_release {
    my ($self) = @_;

    return pf::version::version_get_release();
}

=head2 fingerbank_version

Returns the version of Fingerbank from conf/dhcp_fingerprins.conf

=cut

sub fingerbank_version {
    my $logger = get_logger();
    my ($filehandler, $line, $version);
    open( $filehandler, '<', "$conf_dir/dhcp_fingerprints.conf" )
        || $logger->error("Unable to open $conf_dir/dhcp_fingerprints.conf: $!");
    $line = <$filehandler>; # read the first line
    close $filehandler;
    ($version) = $line =~ m/version ([0-9\.]+)/i;
    return $version;
}

=head2 server_hostname

Returns the server hostname on which PacketFence is actually running

=cut

sub server_hostname {
    my ( $self ) = @_;
    return pf::cluster::get_host_id();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
