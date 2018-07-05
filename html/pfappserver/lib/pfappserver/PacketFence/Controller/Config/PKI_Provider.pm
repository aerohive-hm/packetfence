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
    my ($self, $c, $type) = @_;
    my $logger = get_logger();
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    $c->stash->{$itemKey}{type} = $type;
    $logger->info("model: " .Dumper($c));
    $c->forward('create');
}

sub processCertificate :Path('processCertificate') :Args(1) {
    my ($self, $c, $type) = @_;
    my $logger = get_logger();
    $logger->info("inside acceptCertificate!!!");
    $logger->info("\ntype: $type");
    my $filesize;

    #add PKI unique ID name ($type)

    #make and get file name
    my ($fh, $filename) = @_;
    my $dir = "/tmp";
    my $template = "$type mytempfile XXXXXX";
    #map($template -> $type)
    ($fh, $filename) = tempfile($template, DIR => $dir, SUFFIX => ".pem");
    $filesize = -s "$filename";

    $logger->info("filesize: $filesize \nfilename: $filename");
    # post request, process
    if ($c->request->method eq 'POST'){
        #check if tempfile is valid file and if it's a pem type
        my $checkCertificate = system "/usr/bin/openssl x509 -noout -text -in $filename";
        # my $makeDir = system "mkdir /usr/local/pf/conf/ssl/tls_certs/"
        $logger->info("checkCertificate: $checkCertificate");

        if ($checkCertificate == 0){
            #check if size is <1000000 bytes
            if ($filesize < 1000000){

                move("/tmp/$filename","/usr/local/pf/conf/ssl/tls_certs/$filename");
            }
            else{
                $c->stash->{error_msg} = $c->loc("Certificate size is too big. Try again.");
            }
        }
        else{
            $c->stash->{error_msg} = $c->loc("File is invalid. Try again.");
        }
      }
}

#find rand function
# function for checking names, later?

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
