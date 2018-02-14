package pfappserver::Form::Config::Source::Paypal;

=head1 NAME

pfappserver::Form::Config:::Authentication::Source::Paypal

=cut

=head1 DESCRIPTION

Form definition to create or update a Paypal authentication source.

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
use pf::Authentication::Source::PaypalSource;
extends 'pfappserver::Form::Config::Source::Billing';
with 'pfappserver::Base::Form::Role::Help';

has_field identity_token =>
  (
   type => 'Text',
   required => 1,
  );

has_field cert_id =>
  (
   type => 'Text',
   required => 1,
  );

has_field cert_file =>
  (
   type => 'Path',
   element_class => ['input-xlarge'],
   required => 1,
   tags => { after_element => \&help,
             help => 'The path to the certificate you submitted to Paypal.' },
  );

has_field key_file =>
  (
   type => 'Path',
   element_class => ['input-xlarge'],
   required => 1,
   tags => { after_element => \&help,
             help => 'The path to the associated key of the certificate you submitted to Paypal.' },
  );

has_field paypal_cert_file =>
  (
   type => 'Path',
   element_class => ['input-xlarge'],
   required => 1,
   tags => { after_element => \&help,
             help => 'The path to the Paypal certificate you downloaded.' },
  );

has_field email_address =>
  (
   type => 'Text',
   required => 1,
   tags => { after_element => \&help,
             help => 'The email address associated to your paypal account.' },
  );

has_field payment_type =>
  (
   type     => 'Select',
   required => 1,
   default  => '_xclick',
   options  => [{value => '_xclick', label => 'Buy Now'}, {value => '_donations', label => 'Donations'}],
   tags => { after_element => \&help,
             help => 'The type of transactions this source will do (donations or sales).' },
  );

has_field 'domains' =>
  (
   type => 'Text',
   label => 'Authorized domains',
   required => 1,
   default => pf::Authentication::Source::PaypalSource->meta->get_attribute('domains')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::PaypalSource->meta->get_attribute('domains')->default},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'Comma separated list of domains that will be resolve with the correct IP addresses.' },
  );


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
