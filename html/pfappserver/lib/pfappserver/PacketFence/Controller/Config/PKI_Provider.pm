package pfappserver::PacketFence::Controller::Config::PKI_Provider;

=head1 NAME

pfappserver::PacketFence::Controller::Config::PKI_Provider - Catalyst Controller

=head1 DESCRIPTION

Controller for admin roles management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pf::factory::pki_provider;
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

    $logger->info("inside acceptCertificate!!!");
    $logger->info("\ntype: $type");

    $c->stash->{current_view} = 'JSON';

    if ($c->request->method eq 'POST'){
        my $filename  = $c->request->{uploads}->{file}->{filename};
        my $name      = $c->request->{query_parameters}->{name};
        my $qualifier = $c->request->{query_parameters}->{qualifier};
        my $source    = $c->request->{uploads}->{file}->{tempname};
        my $targetdir = '/usr/local/pf/conf/ssl/tls_certs';
        my $template  = 'cert-XXXXXX';
        my $target    = "$targetdir/$qualifier-$name.pem";
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

        $c->stash->{filePath} = $target;
        $logger->info("Saved certificate at $target");
    }
}

#find rand function
# function for checking names, later?

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
