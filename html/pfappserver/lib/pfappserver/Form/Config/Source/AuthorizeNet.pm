package pfappserver::Form::Config::Source::AuthorizeNet;

=head1 NAME

pfappserver::Form::Config:::Authentication::Source::AuthorizeNet

=cut

=head1 DESCRIPTION

Form definition to create or update an AuthorizeNet authentication source.

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
use pf::Authentication::Source::AuthorizeNetSource;
extends 'pfappserver::Form::Config::Source::Billing';
with 'pfappserver::Base::Form::Role::Help';

has_field api_login_id => (
    label => "API login ID",
    type => 'Text',
    required => 1,
);

has_field transaction_key => (
    label => "Transaction key",
    type => 'Text',
    required => 1,
);

has_field public_client_key => (
    label => 'Public Client Key',
    type => 'Text',
    required => 1,
);

has_field 'domains' =>
  (
   type => 'Text',
   label => 'Authorized domains',
   required => 1,
   default => pf::Authentication::Source::AuthorizeNetSource->meta->get_attribute('domains')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::AuthorizeNetSource->meta->get_attribute('domains')->default},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'Comma separated list of domains that will be resolve with the correct IP addresses.' },
  );

has_block definition => (
    render_list => [qw(api_login_id transaction_key public_client_key domains currency test_mode send_email_confirmation)]
);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
