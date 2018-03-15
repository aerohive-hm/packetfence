package pfappserver::Form::Config::PKI_Provider::packetfence_pki;

=head1 NAME

pfappserver::Form::Config::PKI_Provider::packetfence_pki

=cut

use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

has_field 'id' => (
    type        => 'Text',
    label       => 'PKI Provider Name',
    required    => 1,
    messages    => { required => 'Please specify the name of the PKI provider' },
    tags        => {
        after_element   => \&help,
        help            => 'The unique ID of the PKI provider',
    },
   apply => [ pfappserver::Base::Form::id_validator('PKI provider name') ]
);

has_field 'type' => (
    type        => 'Hidden',
    label       => 'PKI Provider type',
    required    => 1,
);

has_field 'host' => (
    type    => 'Text',
    label   => 'Host',
    default => "127.0.0.1",
    tags    => {
        after_element   => \&help,
        help            => 'Host which hosts the A3 PKI',
    },
);

has_field 'port' => (
    type    => 'Text',
    label   => 'Port',
    default => '9393',
    tags    => {
        after_element   => \&help,
        help            => 'Port on which to contact the A3 PKI API',
    },
);

has_field 'proto' => (
    type    => 'Select',
    label   => 'Protocol',
    default => 'https',
    options => [ { label => 'https', value => 'https' }, { label => 'http', value => 'http' } ],
    tags    => {
        after_element   => \&help,
        help            => 'Protocol to use to contact the A3 PKI API',
    },
);

has_field 'username' => (
    type    => 'Text',
    label   => 'Username',
    tags    => {
        after_element   => \&help,
        help            => 'Username to connect to the PKI',
    },
);

has_field 'password' => (
    type        => 'ObfuscatedText',
    label       => 'Password',
    tags        => {
        after_element   => \&help,
        help            => 'Password for the username filled in above',
    },
);

has_field 'profile' => (
    type    => 'Text',
    label   => 'Profile',
    tags    => {
        after_element   => \&help,
        help            => 'Profile used for the generation of certificate',
    },
);

has_field 'country' => (
    type    => 'Country',
    label   => 'Country',
    tags    => {
        after_element   => \&help,
        help            => 'Country for the certificate',
    },
);

has_field 'state' => (
    type    => 'Text',
    label   => 'State',
    tags    => {
        after_element   => \&help,
        help            => 'State for the certificate',
    },
);

has_field 'organization' => (
    type    => 'Text',
    label   => 'Organization',
    tags    => {
        after_element   => \&help,
        help            => 'Organization for the certificate',
    },
);

has_field 'ca_cert_path' => (
    type        => 'Path',
    label       => 'CA cert path',
    required    => 1,
    tags        => {
        after_element   => \&help,
        help            => 'Path of the CA certificate that will generate your certificates',
    },
);

has_field 'cn_attribute' => (
    type    => 'Select',
    label   => 'Common Name Attribute',
    options => [ { label => 'MAC address', value => 'mac' }, { label => 'Username', value => 'pid' } ],
    default => 'pid',
    tags    => {
        after_element   => \&help,
        help            => 'Defines what attribute of the node to use as the common name during the certificate generation',
    },
);

has_field 'cn_format' => (
    type    => 'Text',
    label   => 'Common Name Format',
    default => '%s',
    tags    => {
        after_element   => \&help,
        help            => 'Defines how the common name will be formated. %s will expand to the defined Common Name Attribute value',
    },
);

has_field 'server_cert_path' => (
    type        => 'Path',
    label       => 'Server cert path',
    required    => 1,
    tags        => {
        after_element   => \&help,
        help            => 'Path of the RADIUS server authentication certificate',
    },
);

has_field 'revoke_on_unregistration' => (
    type             => 'Checkbox',
    label            => 'Revoke on unregistration',
    checkbox_value   => 'Y',
    tags             => {
        after_element   => \&help,
        help            => 'Check this box to have the certificate revoke when the node using it is unregistered.<br/>Do not use if multiple devices share the same certificate',
    },
);

has_block 'definition' => (
    render_list => [ qw(type proto host port username password profile country state organization cn_attribute cn_format revoke_on_unregistration ca_cert_path server_cert_path) ],
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
