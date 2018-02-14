package pfappserver::Form::Config::Source::Twitter;

=head1 NAME

pfappserver::Form::Config::Source::Twitter - Web form for a Twitter user source

=head1 DESCRIPTION

Form definition to create or update a Twitter user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';

use pf::Authentication::Source::TwitterSource;

# Form fields
has_field 'client_id' =>
  (
   type => 'Text',
   label => 'API ID',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('client_id')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::TwitterSource->meta->get_attribute('client_id')->default},
   element_class => ['input-xlarge'],
  );
has_field 'client_secret' =>
  (
   type => 'Text',
   label => 'API Secret',
   required => 1,
   # Default value needed for creating dummy source
   default => '',
  );
has_field 'site' =>
  (
   type => 'Text',
   label => 'API URL',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('site')->default,
   element_class => ['input-xlarge'],
  );
has_field 'authorize_path' =>
  (
   type => 'Text',
   label => 'API Authorize Path',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('authorize_path')->default,
  );
has_field 'access_token_path' =>
  (
   type => 'Text',
   label => 'API Token Path',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('access_token_path')->default,
  );
has_field 'protected_resource_url' =>
  (
   type => 'Text',
   label => 'API URL of logged user',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('protected_resource_url')->default,
   element_class => ['input-xlarge'],
  );
has_field 'redirect_url' =>
  (
   type => 'Text',
   label => 'Portal URL',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('redirect_url')->default,,
   element_attr => {'placeholder' => pf::Authentication::Source::TwitterSource->meta->get_attribute('redirect_url')->default,},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'The hostname must be the one of your captive portal.' },
  );
has_field 'domains' =>
  (
   type => 'Text',
   label => 'Authorized domains',
   required => 1,
   default => pf::Authentication::Source::TwitterSource->meta->get_attribute('domains')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::TwitterSource->meta->get_attribute('domains')->default},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'Comma separated list of domains that will be resolve with the correct IP addresses.' },
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
