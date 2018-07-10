package pfappserver::Model::Config::PKI_Provider;

=head1 NAME

pfappserver::Model::Config::PKI_Provider

=head1 DESCRIPTION

pfappserver::Model::Config::PKI_Provider

The Config Model for PKI_Provider

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::ConfigStore::PKI_Provider;
use pf::ConfigStore::Provisioning;
use pf::log;
use File::Basename;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::PKI_Provider->new }

=head2 remove

Override the parent method to validate we don't remove a PKI provider that is used in a provisioner

=cut

sub remove {
    my ($self, $id) = @_;
    my $logger = get_logger();
    $logger->info("Deleting $id");
    my @results = pf::ConfigStore::Provisioning->new->search("pki_provider", $id, "id");
    if(@results){
        my @ids = map { $_->{id} } @results;
        my $csv = join(', ', @ids);
        my $status_msg = ["Cannot remove provider [_1] because it is still used by the following provisioners : [_2]",$id, $csv];
        my $status =  HTTP_PRECONDITION_FAILED;
        return ($status, $status_msg);
    }
    else {
        my ($obj_status, $obj) = $self->read($id);
        my ($status, $status_msg) = $self->SUPER::remove($id);
        if (is_success($status) && is_success($obj_status)) {
            if(unlink($obj->{server_cert_path}) != 1) {
                $logger->warn("Failed to remove server cert for [_1] at [_2] $!",$id, $obj->{server_cert_path});
            }
            if(unlink($obj->{ca_cert_path}) != 1) {
                $logger->warn("Failed to remove ca cert for [_1] at [_2] $!",$id, $obj->{ca_cert_path});
            }
        }
        return ($status, $status_msg);
    }
}

=head2 copy_cert

copies the certificates

=cut

sub copy_cert {
    my $logger = get_logger();
    my ($file_from, $file_to) = (@_);
    my ($status, $status_msg) = (HTTP_OK, "");
    if ((system("/usr/bin/cp -f $file_from $file_to") >> 8) != 0) {
        $logger->warn("Failed to copy $file_from to $file_to $!");
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "Unable to clone certificate. Try again.";
    }
    return($status, $status_msg);
}

=head2 create

Override the parent method to clone the old pki_provider config

=cut

sub create {
    my ($self, $id, $assignments) = @_;
    my ($status, $status_msg) = (HTTP_OK, "");
    my $old_id_server = fileparse($assignments->{server_cert_path}, qr/\.[^.]*/);
    $old_id_server = substr ($old_id_server, 0, -7);
    my $old_id_ca = fileparse($assignments->{ca_cert_path}, qr/\.[^.]*/);
    $old_id_ca = substr ($old_id_ca, 0, -3);
    my $targetdir = '/usr/local/pf/conf/ssl/tls_certs';
    my $server_filename = "$targetdir/$id-Server.pem";
    my $ca_filename = "$targetdir/$id-CA.pem";

    #check if the server/CA certificate is changed or not
    if ($old_id_server ne $id) {
        ($status, $status_msg) = copy_cert($assignments->{server_cert_path}, $server_filename);
        if (is_error($status)) {
            return ($status, $status_msg);
        }
        $assignments->{server_cert_path} = $server_filename;
    }

    if ($old_id_ca ne $id) {
        ($status, $status_msg) = copy_cert($assignments->{ca_cert_path}, $ca_filename);
        if (is_error($status)) {
            unlink($server_filename);
            return ($status, $status_msg);
        }
        $assignments->{ca_cert_path} = $ca_filename;
    }
    return $self->SUPER::create($id, $assignments);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
