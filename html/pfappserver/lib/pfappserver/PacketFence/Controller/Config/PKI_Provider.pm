package pfappserver::PacketFence::Controller::Config::PKI_Provider;

=head1 NAME

pfappserver::PacketFence::Controller::Config::PKI_Provider - Catalyst Controller

=head1 DESCRIPTION

Controller for admin roles management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use pf::constants qw($TRUE $FALSE );
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pf::factory::pki_provider;
use pf::cluster;
use strict;
use warnings;
#for file processing
use File::Temp qw/ tempfile /;
use File::Basename;
use File::Path;
use File::Spec::Functions;
use File::Copy; #to move files over and change name

use pf::log;
use Data::Dumper;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/pki_provider', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'PKI_PROVIDER_READ' },
        list   => { AdminRole => 'PKI_PROVIDER_READ' },
        create => { AdminRole => 'PKI_PROVIDER_CREATE' },
        clone  => { AdminRole => 'PKI_PROVIDER_CREATE' },
        update => { AdminRole => 'PKI_PROVIDER_UPDATE' },
        remove => { AdminRole => 'PKI_PROVIDER_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::PKI_Provider", form => "Config::PKI_Provider" },
    },
);

=head1 METHODS

=head2 index

Usage: /config/pki_provider

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my %pki_providers = ();
    foreach my $module ( keys %pf::factory::pki_provider::MODULES ) {
        my $type = $pf::factory::pki_provider::MODULES{$module}{'type'};
        $pki_providers{$type}{'type'} = $type;
        $pki_providers{$type}{'description'} = $pf::factory::pki_provider::MODULES{$module}{'description'};
    }
    $c->stash->{types} = \%pki_providers;

    $c->forward('list');
}

before [qw(clone view _processCreatePost update)] => sub {
    my ($self, $c, @args) = @_;
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    my $item = $c->stash->{$itemKey};
    my $type = $item->{type};
    my $form = $c->action->{form};
    $c->stash->{current_form} = "${form}::${type}";
};

sub create_type : Path('create') : Args(1) {
    my ($self, $c, $type, $assignments) = @_;
    # my $logger = get_logger();
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    $c->stash->{$itemKey}{type} = $type;
    # $logger->info("assignments: " .Dumper($assignments));
    # $logger->info("assignments: $assignments");
    $c->forward('create');

}

sub processCertificate :Path('processCertificate') :Args(1) {
    my ($self, $c, $type) = @_;

    my $logger = get_logger();

    $c->stash->{current_view} = 'JSON';

    if ($c->request->method eq 'POST'){
        my $filename  = $c->request->{uploads}->{file}->{filename};
        my $name      = $c->request->{query_parameters}->{name};
        my $qualifier = $c->request->{query_parameters}->{qualifier};
        my $source    = $c->request->{uploads}->{file}->{tempname};
        my $targetdir = '/usr/local/pf/conf/ssl/tls_certs';
        my $template  = 'cert-XXXXXX';
        my $target    = "$targetdir/$name-$qualifier.pem";
        my $tempfile  = "/usr/local/pf/conf/ssl/tls_certs/cert-XXXXXX.tmp";
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

        my (undef, $tmp_filename) = tempfile($template, DIR => $targetdir, SUFFIX => ".tmp");

        if ((system("/usr/bin/cp -f $source $tmp_filename") >> 8) != 0) {
            $logger->warn("Failed to save file data: $!");
            unlink($tmp_filename);

            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
            return;
        }

        if ( ! rename($tmp_filename, $target) ) {
            $logger->warn("Failed to move certificate file $filename into place at $target: $!");
            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to install certificate. Try again.");
            return;
        }

        if ( pf::cluster::add_file_to_cluster_sync($target) ) {
            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
            $c->stash->{status_msg} = $c->loc("Unable to save certificate to cluster. Try again.");
            return;
        }

        $c->stash->{filePath} = $target;
        $logger->info("Saved certificate at $target");
    }
}

sub uploadCerts :Path('uploadCerts') :Args(1) {
    my ($self, $c) = @_;

    my $logger = get_logger();

    $c->stash->{current_view} = 'JSON';

    if ($c->request->method eq 'POST'){
        my $CA_file  = $c->request->{uploads}->{file}->[0]->{filename};
        my $server_file  = $c->request->{uploads}->{file}->[1]->{filename};
        my $name      = $c->request->{query_parameters}->{name};
        my $CA_source    = $c->request->{uploads}->{file}->[0]->{tempname};
        my $server_source    = $c->request->{uploads}->{file}->[1]->{tempname};
        my $CA_file_path;
        my $server_file_path;
        my ($status, $status_msg) = _validate_cert($CA_file, $CA_source);
        if (!is_success($status)) {
            $c->response->status($status);
            $c->stash->{status_msg} = $c->loc($status_msg);
            return;
        }

        ($status, $status_msg) = _validate_cert($server_file, $server_source);
        if (!is_success($status)) {
            $c->response->status($status);
            $c->stash->{status_msg} = $c->loc($status_msg);
            return;
        }

        ($status, $status_msg, $CA_file_path) = _save_cert($CA_file, $CA_source, $name, "CA");
        if (!is_success($status)) {
            $c->response->status($status);
            $c->stash->{status_msg} = $c->loc($status_msg);
            return;
        }

        ($status, $status_msg, $server_file_path) = _save_cert($server_file, $server_source, $name, "Server");
        if (!is_success($status)) {
            $c->response->status($status);
            $c->stash->{status_msg} = $c->loc($status_msg);
            unlink($CA_file_path);
            return;
        }

        $c->stash->{CA_file_path} = $CA_file_path;
        $c->stash->{Server_file_path} = $server_file_path;
        $c->response->status($STATUS::OK);
        $logger->info("Saved CA-certificate at $CA_file_path, server-certificate at $server_file_path");
    }
}

sub _validate_cert {
    my ($filename, $source) = @_;
    my $logger = get_logger();

    my $filesize  = -s $source;
    my $status_msg;
    $logger->info("filename: $filename, size: $filesize, location: $source");

    if ($filesize && $filesize > 1000000) {
        $logger->warn("Uploaded file $filename is too large");
        return $STATUS::BAD_REQUEST, "Certificate size is too big. Try again.";
    }

    my $ret = system("/usr/bin/openssl x509 -noout -text -in $source");

    if (($ret >> 8) != 0) {
        $logger->warn("Uploaded file $filename is not a certificate in PEM format");
        return $STATUS::BAD_REQUEST, "File is invalid. Try again.";
    }

    return $STATUS::OK, "";


}

sub _save_cert {
    my ($filename, $source, $pki_id, $qualifier) = @_;
    my $logger = get_logger();
    my $targetdir = '/usr/local/pf/conf/ssl/tls_certs';
    my $target    = "$targetdir/$pki_id-$qualifier.pem";
    my $template  = 'cert-XXXXXX';
    my (undef, $tmp_filename) = tempfile($template, DIR => $targetdir, SUFFIX => ".tmp");

    if ((system("/usr/bin/cp -f $source $tmp_filename") >> 8) != 0) {
        $logger->warn("Failed to save file data: $!");
        return $STATUS::INTERNAL_SERVER_ERROR, "Unable to install certificate. Try again.", undef;
    }

    if ( ! rename($tmp_filename, $target) ) {
        $logger->warn("Failed to move certificate file $filename into place at $target: $!");
        return $STATUS::INTERNAL_SERVER_ERROR, "Unable to install certificate. Try again.", undef;
    }

    if ( pf::cluster::add_file_to_cluster_sync($target) ) {
        $logger->warn("Failed to save file $target to cluster sync");
        return $STATUS::INTERNAL_SERVER_ERROR, "Unable to save certificate to cluster. Try again.", undef;
    }

    return $STATUS::OK, "", $target;
}

#find rand function
# function for checking names, later?

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
