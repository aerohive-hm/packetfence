package pfappserver::Form::Config::PKI_Provider::scep;

=head1 NAME

pfappserver::Form::Config::PKI_Provider

=head1 DESCRIPTION

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants is_error is_success);
use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';
use HTML::FormHandler::Field::Upload;

use pf::log;

use pf::factory::pki_provider;

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'PKI Provider Name',
   required => 1,
   messages => { required => 'Please specify the name of the PKI provider' },
   tags => { after_element => \&help,
             help => 'The unique ID of the PKI provider'},
   apply => [ pfappserver::Base::Form::id_validator('PKI provider name') ]
  );

has_field 'type' =>
  (
   type => 'Hidden',
   required => 1,
  );

has_field 'url' =>
  (
   type => 'Text',
   label => 'URL',
   tags => { after_element => \&help,
             help => 'The URL used to connect to the SCEP PKI service'},
  );

has_field 'username' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'Username to connect to the SCEP PKI Service'},
  );

has_field 'password' =>
  (
   type => 'ObfuscatedText',
   tags => { after_element => \&help,
             help => 'Password for the username filled in above'},
  );

has_field 'country' =>
  (
   type => 'Country',
   tags => { after_element => \&help,
             help => 'Country for the certificate'},
  );

has_field 'state' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'State for the certificate'},
  );

has_field 'locality' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'Locality for the certificate'},
  );

has_field 'organization' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'Organization for the certificate'},
  );

has_field 'organizational_unit' =>
  (
   type => 'Text',
   label => 'Organizational Unit',
   tags => { after_element => \&help,
             help => 'Organizational unit for the certificate'},
  );

has_field 'ca_cert_path_upload' =>
  (
   type     => 'Upload',
   label    => 'CA Certificate',
   required => 0,
   tags     => { after_element => \&help,
             help => 'When uploading, make sure the file is under 1MB (1 megabyte or 1000000 bytes) and in PEM format.'},
  );

has_field 'ca_cert_path' =>
  (
   type     => 'Hidden',
   label    => 'CA Certificate Path',
   required => 1,
   );

has_field 'ca_cert_subject' =>
  (
   type     => 'Hidden',
   required => 0,
   );

has_field 'server_cert_path_upload' =>
  (
   type => 'Upload',
   label    => 'Server Certificate',
   required => 0,
   tags => { after_element => \&help,
             help => 'When uploading, make sure the file is under 1MB (1 megabyte or 1000000 bytes) and in PEM format.' },
  );

has_field 'server_cert_path' =>
  (
   type => 'Hidden',
   label    => 'Server Certificate Path',
   required => 1,
  );

has_field 'server_cert_subject' =>
  (
   type => 'Hidden',
   required => 0,
  );

has_field 'cn_attribute' =>
  (
   type => 'Select',
   label => 'Common Name Attribute',
   options => [{ label => 'MAC address', value => 'mac' }, { label => 'Username' , value => 'pid' }],
   default => 'pid',
   tags => { after_element => \&help,
             help => 'Defines what attribute of the node to use as the common name during the certificate generation.' },
  );

has_field 'cn_format' => (
    type    => 'Text',
    label   => 'Common Name Format',
    default => '%s',
    tags    => {
        after_element   => \&help,
        help            => 'Defines how the common name will be formatted. %s will expand to the defined Common Name Attribute value',
    },
);

has_block definition =>
  (
    render_list => [qw(type url username password country state locality organization organizational_unit cn_attribute cn_format ca_cert_path ca_cert_path_upload ca_cert_subject server_cert_path server_cert_path_upload server_cert_subject)],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
