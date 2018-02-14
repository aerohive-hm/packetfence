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
    type => 'Text',
    required => 1,
    # Default value needed for creating dummy source
    default => '',
);

has_field transaction_key => (
    type => 'Text',
    required => 1,
    # Default value needed for creating dummy source
);

has_field md5_hash => (
    label => 'MD5 hash',
    type => 'Text',
    required => 1,
    # Default value needed for creating dummy source
    default => '',
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

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
