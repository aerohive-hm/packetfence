package pfappserver::PacketFence::Controller::CertificateUpload;

=head1 NAME

pfappserver::PacketFence::Controller::CertificateUpload - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use Moose;
use pf::error qw(is_success is_error);

use pf::log;
use pf::util;
use Data::Dumper;
use File::Temp qw/ tempfile /;
use File::Basename;
use File::Path;
use File::Spec::Functions;
use File::Copy; #to move files over and change name
use pf::file_paths qw(
    $server_cert
    $server_key
    $server_pem
    $radius_server_key
    $radius_server_cert
    $radius_ca_cert
);

BEGIN {extends 'pfappserver::Base::Controller';}

=head1 METHODS

=head2 begin

This controller defaults view is JSON.

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
    $c->stash->{current_view} = 'JSON';
}

=head2 uploadKey

Upload Certificate Key

Usage: /uploadKey

=cut

sub uploadKey :Chained('/') :PathPart('uploadKey') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;

    my $logger = get_logger();

    $logger->info("jma_debug in uploadKey");
    # $logger->info("\ntype: $type");

    if ($c->request->method eq 'POST'){
        my $filename  = $c->request->{uploads}->{file}->{filename};
        my $name      = $c->request->{query_parameters}->{name};
        my $qualifier = $c->request->{query_parameters}->{qualifier};
        my $source    = $c->request->{uploads}->{file}->{tempname};
        my $targetdir = '/usr/local/pf/conf/ssl';
        my $template  = 'cert-XXXXXX';
        my $tempfile  = "/usr/local/pf/conf/ssl/tls_certs/cert-XXXXXX.tmp";
        my $filesize  = -s $source;

        $logger->info("filename: $filename, size: $filesize, location: $source");

        if ($filesize && $filesize > 8000) {
            $logger->warn("Uploaded file $filename is too large");
            $c->response->status($STATUS::BAD_REQUEST);
            $c->stash->{status_msg} = $c->loc("Certificate key size is too big. Try again.");
            return;
        }

        my $ret = system("/usr/bin/openssl rsa -in $source -check");

        if (($ret >> 8) != 0) {
            $logger->warn("Uploaded file $filename is not a certificate key in KEY format");
            $c->response->status($STATUS::BAD_REQUEST);

            $c->stash->{status_msg} = $c->loc("File is invalid. Try again.");
            $logger->info("jma_debug c: " .Dumper($c));
            return;
        }

        my (undef, $tmp_filename) = tempfile($template, DIR => $targetdir, SUFFIX => ".key");

        if ((system("/usr/bin/cp -f $source $tmp_filename") >> 8) != 0) {
            $logger->warn("Failed to save file data: $!");
            unlink($tmp_filename);

            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to install certificate key. Try again.");
            return;
        }
        #
        # if ( ! rename($tmp_filename, $target) ) {
        #     $logger->warn("Failed to move certificate file $filename into place at $target: $!");
        #     $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
        #     $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
        #     return;
        # }

        # if ( pf::cluster::add_file_to_cluster_sync($target) ) {
        #     $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
        #     $c->stash->{status_msg} = $c->loc("Unable to save certificate to cluster. Try again.");
        #     return;
        # }

        $c->stash->{filePath} = $tmp_filename;
        $logger->info("Saved certificate key at $tmp_filename");
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

=head2 uploadServerCert

Upload Server Certificate

Usage: /uploadServerCert

=cut

sub uploadServerCert :Chained('/') :PathPart('uploadServerCert') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;

    my $logger = get_logger();

    $logger->info("jma_debug inside uploadServerCert");

    if ($c->request->method eq 'POST'){
        my $filename  = $c->request->{uploads}->{file}->{filename};
        my $source    = $c->request->{uploads}->{file}->{tempname};
        my $targetdir = '/usr/local/pf/conf/ssl';
        my $template  = 'cert-XXXXXX';
        my $filesize  = -s $source;

        $logger->info("filename: $filename, size: $filesize, location: $source");

        if ($filesize && $filesize > 1000000) {
            $logger->warn("Uploaded file $filename is too large");
            $c->response->status($STATUS::BAD_REQUEST);
            $c->stash->{status_msg} = $c->loc("Certificate size is too big. Try again.");
            return;
        }

        my $ret = system("/usr/bin/openssl x509 -noout -text -in $source");

        if (($ret >> 8) != 0) {
            $logger->warn("Uploaded file $filename is not a certificate in PEM format");
            $c->response->status($STATUS::BAD_REQUEST);
            $c->stash->{status_msg} = $c->loc("File is invalid. Try again.");
            return;
        }

        my (undef, $tmp_filename) = tempfile($template, DIR => $targetdir, SUFFIX => ".pem");

        if ((system("/usr/bin/cp -f $source $tmp_filename") >> 8) != 0) {
            $logger->warn("Failed to save file data: $!");
            unlink($tmp_filename);

            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to install certificate key. Try again.");
            return;
        }
        #
        # if ( ! rename($tmp_filename, $target) ) {
        #     $logger->warn("Failed to move certificate file $filename into place at $target: $!");
        #     $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
        #     $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
        #     return;
        # }

        # if ( pf::cluster::add_file_to_cluster_sync($target) ) {
        #     $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
        #     $c->stash->{status_msg} = $c->loc("Unable to save certificate to cluster. Try again.");
        #     return;
        # }

        $c->stash->{filePath} = $tmp_filename;
        $logger->info("Saved server certificate at $tmp_filename");
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }

}

=head2 uploadCACert

Upload CA Certificate

Usage: /uploadCACert

=cut

sub uploadCACert :Chained('/') :PathPart('uploadCACert') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;

    my $logger = get_logger();

    $logger->info("jma_debug inside uploadCACert");

    if ($c->request->method eq 'POST'){
        my $filename  = $c->request->{uploads}->{file}->{filename};
        my $source    = $c->request->{uploads}->{file}->{tempname};
        my $targetdir = '/usr/local/pf/conf/ssl';
        my $template  = 'cert-XXXXXX';
        my $filesize  = -s $source;

        $logger->info("filename: $filename, size: $filesize, location: $source");

        if ($filesize && $filesize > 1000000) {
            $logger->warn("Uploaded file $filename is too large");
            $c->response->status($STATUS::BAD_REQUEST);
            $c->stash->{status_msg} = $c->loc("Certificate size is too big. Try again.");
            return;
        }

        my $ret = system("/usr/bin/openssl x509 -noout -text -in $source");

        if (($ret >> 8) != 0) {
            $logger->warn("Uploaded file $filename is not a certificate in PEM format");
            $c->response->status($STATUS::BAD_REQUEST);
            $c->stash->{status_msg} = $c->loc("File is invalid. Try again.");
            return;
        }

        my (undef, $tmp_filename) = tempfile($template, DIR => $targetdir, SUFFIX => ".pem");

        if ((system("/usr/bin/cp -f $source $tmp_filename") >> 8) != 0) {
            $logger->warn("Failed to save file data: $!");
            unlink($tmp_filename);

            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to install CA certificate. Try again.");
            return;
        }

        if ( ! rename($tmp_filename, $radius_ca_cert) ) {
            $logger->warn("Failed to move certificate file $filename into place at $radius_ca_cert: $!");
            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
            return;
        }

        $c->stash->{filePath} = $radius_ca_cert;
        $c->stash->{status_msg} = $c->loc("Successfully uploaded the CA-Cert!");
        $logger->info("Saved radius CA certificate at $radius_ca_cert");
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }

}
=head2 verifyCert

verify the key and server cert files
Usage: /verifyCert

=cut

sub verifyCert :Chained('/') :PathPart('verifyCert') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;

    my $logger = get_logger();
    $logger->info("jma_debug inside verifyCert");

    if ($c->request->method eq 'POST') {
        my $qualifier = $c->request->{query_parameters}->{qualifier};
        my $key_path = $c->request->{query_parameters}->{key_path};
        my $cert_path = $c->request->{query_parameters}->{cert_path};
        my $cn_server;
        $logger->info("jma_debug key_path $key_path cert_path $cert_path qualifier $qualifier");
        my $key_md5 = `openssl rsa -noout -modulus -in $key_path| openssl md5`;
        my $cert_md5 = `openssl x509 -noout -modulus -in $cert_path| openssl md5`;
        $logger->info("jma_debug key_md5 $key_md5 cert_md5 $cert_md5");
        if ($key_md5 eq $cert_md5) {
            #eap-tls certs will be put in raddb/certs
            if ($qualifier eq "eap") {
                $logger->info("jma_debug inside eap verify");
                if ( ! rename($key_path, $radius_server_key) ) {
                    $logger->warn("Failed to move certificate file $key_path into place at $radius_server_key: $!");
                    $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
                    $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
                    return;
                }
                if ( ! rename($cert_path, $radius_server_cert) ) {
                    $logger->warn("Failed to move certificate file $cert_path into place at $radius_server_cert: $!");
                    $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
                    $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
                    return;
                }

                $c->stash->{CN_Server} = pf::util::get_cert_subject_cn($radius_server_cert);
            } elsif ($qualifier eq "https") {
                $logger->info("jma_debug inside https verify");
                #https certs will be put in conf/ssl
                if ( ! rename($key_path, $server_key) ) {
                    $logger->warn("Failed to move certificate file $key_path into place at $server_key: $!");
                    $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
                    $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
                    return;
                }
                if ( ! rename($cert_path, $server_cert) ) {
                    $logger->warn("Failed to move certificate file $cert_path into place at $server_cert: $!");
                    $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
                    $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
                    return;
                }

                $cn_server = pf::util::get_cert_subject_cn($server_cert);
                $logger->info("jma_debug CN_server $cn_server");
                system("cat $server_cert $server_key > $server_pem");
                $c->stash->{CN_Server} = pf::util::get_cert_subject_cn($server_cert);
            }
        } else {
            $logger->warn("Failed to verify certificate file $key_path against $cert_path");
            $c->response->status($STATUS::UNPROCESSABLE_ENTITY);
            if(unlink($key_path) != 1) {
                $logger->warn("Failed to remove $key_path, $!");
            }
            if(unlink($cert_path) != 1) {
                $logger->warn("Failed to remove $cert_path $!");
            }
            $c->stash->{status_msg} = $c->loc("Unable to verify certificate. Try again.");
            return;
        }
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }

}

=head2 readCert

reads the Subject of the certs
Usage: /readCert

=cut

sub readCert :Chained('/') :PathPart('readCert') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;
    my $logger = get_logger();
    $logger->info("jma_debug inside readCert");

    if ($c->request->method eq 'GET') {
        my $qualifier = $c->request->{query_parameters}->{qualifier};
        if ($qualifier eq "https") {
            $c->stash->{CN_Server} = pf::util::get_cert_subject_cn($server_cert);
            $c->stash->{Server_INFO} = `/usr/bin/openssl x509 -noout -text -in $server_cert`;
        } elsif ($qualifier eq "eap") {
            $c->stash->{CN_Server} = pf::util::get_cert_subject_cn($radius_server_cert);
            $c->stash->{CN_CA} = pf::util::get_cert_subject_cn($radius_ca_cert);
            $c->stash->{Server_INFO} = `/usr/bin/openssl x509 -noout -text -in $radius_server_cert`;
            $c->stash->{CA_INFO} = `/usr/bin/openssl x509 -noout -text -in $radius_ca_cert`;
        }
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

=head2 downloadCert

downloads the specified certs
Usage: /downloadCert

=cut

sub downloadCert :Chained('/') :PathPart('downloadCert') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;
    my $logger = get_logger();
    my $cert_path;
    my $cert;
    my $in;
    $logger->info("jma_debug inside readCert");

    if ($c->request->method eq 'GET') {
        my $qualifier = $c->request->{query_parameters}->{qualifier};
        if ($qualifier eq 'https') {
            $cert_path = $server_cert;
        } elsif ($qualifier eq 'eap') {
            $cert_path = $radius_server_cert;
        } elsif ($qualifier eq 'eap-ca') {
            $cert_path = $radius_ca_cert;
        } else {
            $c->response->status($STATUS::BAD_REQUEST);
            $c->stash->{status_msg} = $c->loc("Unable to download the certificate");
            return;
        }

        unless (open($in, '<', $cert_path) ) {
            $logger->error("Failed to open $cert_path to sync $!");
            return;
        }
        #read the cert
        read $in, $cert, -s $in;
        close($in);

        $c->stash->{Cert_Content} = $cert;
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

=head2 removeCert

removes the specified certs
Usage: /removeCert

=cut

sub removeCert :Chained('/') :PathPart('removeCert') :Args(0) :AdminRole('CERTIFICATE_UPDATE') {
    my ($self, $c) = @_;
    my $logger = get_logger();

    $logger->info("jma_debug inside removeCert");

    if ($c->request->method eq 'POST') {
        my $cert_path = $c->request->{query_parameters}->{file_path};
        if (-e $cert_path) {
            $logger->info("Removing $cert_path");
            if(unlink($cert_path) != 1) {
                $logger->warn("Failed to remove $cert_path $!");
                $c->stash->{status_msg} = $c->loc("Unable to remove the certificate file!");
                $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
                return;
            }

        } else {
            $logger->warn("Unable to find $cert_path $!");
            $c->stash->{status_msg} = $c->loc("Unable to remove the certificate file!");
            $c->response->status($STATUS::BAD_REQUEST);
            return;
        }
        $c->stash->{status_msg} = $c->loc("Removed the certificate file from the server!");
        $c->response->status($STATUS::OK);
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
