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

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
