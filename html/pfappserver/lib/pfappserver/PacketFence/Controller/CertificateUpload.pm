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
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

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

Usage: /uploadKey/<type>

=cut

sub uploadKey :Path('/uploadKey') :Args(0) {
    my ($self, $c) = @_;

    my $logger = get_logger();

    $logger->info("jma_debug in uploadKey");
    # $logger->info("\ntype: $type");

    # if ($c->request->method eq 'POST'){
    #     my $filename  = $c->request->{uploads}->{file}->{filename};
    #     my $name      = $c->request->{query_parameters}->{name};
    #     my $qualifier = $c->request->{query_parameters}->{qualifier};
    #     my $source    = $c->request->{uploads}->{file}->{tempname};
    #     my $targetdir = '/usr/local/pf/conf/ssl/tls_certs';
    #     my $template  = 'cert-XXXXXX';
    #     my $target    = "$targetdir/$name-$qualifier.pem";
    #     my $tempfile  = "/usr/local/pf/conf/ssl/tls_certs/cert-XXXXXX.tmp";
    #     my $filesize  = -s $source;
    #
    #     $logger->info("filename: $filename, size: $filesize, location: $source");
    #
    #     if ($filesize && $filesize > 1000000) {
    #         $logger->warn("Uploaded file $filename is too large");
    #         $c->response->status($STATUS::BAD_REQUEST);
    #         $c->stash->{status_msg} = $c->loc("Certificate size is too big. Try again.");
    #         return;
    #     }
    #
    #     my $ret = system("/usr/bin/openssl x509 -noout -text -in $source");
    #
    #     if (($ret >> 8) != 0) {
    #         $logger->warn("Uploaded file $filename is not a certificate in PEM format");
    #         $c->response->status($STATUS::BAD_REQUEST);
    #         $c->stash->{status_msg} = $c->loc("File is invalid. Try again.");
    #         return;
    #     }
    #
    #     my (undef, $tmp_filename) = tempfile($template, DIR => $targetdir, SUFFIX => ".tmp");
    #
    #     if ((system("/usr/bin/cp -f $source $tmp_filename") >> 8) != 0) {
    #         $logger->warn("Failed to save file data: $!");
    #         unlink($tmp_filename);
    #
    #         $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
    #         $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
    #         return;
    #     }
    #
    #     if ( ! rename($tmp_filename, $target) ) {
    #         $logger->warn("Failed to move certificate file $filename into place at $target: $!");
    #         $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
    #         $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
    #         return;
    #     }
    #
    #     if ( pf::cluster::add_file_to_cluster_sync($target) ) {
    #         $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
    #         $c->stash->{status_msg} = $c->loc("Unable to save certificate to cluster. Try again.");
    #         return;
    #     }
    #
    #     $c->stash->{filePath} = $target;
    #     $logger->info("Saved certificate at $target");
    # }
}



__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
