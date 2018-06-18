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

#for file processing
use File::Temp qw/ tempdir /;
use File::Basename;
use File::Path;
use File::Spec::Functions;

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

    # do log prints to trace
    my $model = $self->getModel($c);
    my $itemKey = $model->itemKey;
    $c->stash->{$itemKey}{type} = $type;
    $c->forward('create');
}

sub acceptCertificate :Args(1) {
    my ($self, $c, $tempfile) = @_;
    my $logger = get_logger();

    #make and get file name
    $template = "mytempfileXXXXXX";
    ($fh, $filename) = tempfile($template, SUFFIX => ".pem");
    # print "filename: $filename";

    # get file type
    my $ft = File::Type->new();
    my $type_from_file = $ft->checktype_filename($tempfile);
    my $type_1 = $ft->mime_type($tempfile);
    # print "type_1 $type_1";
    # print "type from file $type_from_file"

    #get file size
    my $filesize = -s "$tempfile";
    # print "Size: $filesize\n";

    $logger->info("filesize: $filesize\n filename: $filename\n type from file: $type_from_file");
    # post request, process
    # if ($c->request->method eq 'POST'){
        #check if tempfile is valid file
        # my $checkCertificate = system "/usr/bin/openssl x509 -noout -text -in $tempfile";
        # print "checkCertificate:  $checkCertificate";
        # if ($checkCertificate == 0){
        #check if type is .pem
            # if ($type_1 == ".pem"){
              #check if size is <1000000 bytes
                # if ($filesize < 1000000){
                     #take file name and change it

                     #move to that location
        #
        #         }
        #         else{
        #             $c->stash->{error_msg} = $c->loc("Certificate size is too big. Try again.");
        #         }
        #     }
        #     else{
        #         $c->stash->{error_msg} = $c->loc("Certificate file is not correct. Try again.");
        #     }
        #
        # }

    # }
#     if ($checkCertificate == 0) {
#         1. Tempfile save
#         2. Check file size
        # 3. Check file type
        # 4. Take name and make unique identifier
        # 5. Put into folder
#     }
#     else{
#        return status 500 - > message to client
          # Select a valid certificate
#     }
}

#function for names to change and add to the name of the file.
#find rand function
# function for checking names

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
