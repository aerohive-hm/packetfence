package pfappserver::Form::Config::Source::HTTP;

=head1 NAME

pfappserver::Form::Config::Source::HTTP - Web form for a HTTP user source

=head1 DESCRIPTION

Form definition to create or update a HTTP user source.

=cut

use HTML::FormHandler::Moose;
use pf::Authentication::Source::HTTPSource;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help', 'pfappserver::Base::Form::Role::InternalSource';

# Form fields
has_field 'host' =>
  (
   type => 'Text',
   label => 'Host',
   element_class => ['input-small'],
   element_attr => {'placeholder' => pf::Authentication::Source::HTTPSource->meta->get_attribute('host')->default},
   default => pf::Authentication::Source::HTTPSource->meta->get_attribute('host')->default,
  );
has_field 'port' =>
  (
   type => 'PosInteger',
   label => 'Port',
   element_class => ['input-mini'],
   element_attr => {'placeholder' => pf::Authentication::Source::HTTPSource->meta->get_attribute('port')->default},
   default => pf::Authentication::Source::HTTPSource->meta->get_attribute('port')->default,
  );

has_field 'protocol' =>
  (
   type => 'Select',
   label => 'Encryption',
   options => 
   [
    { value => 'http', label => 'http' },
    { value => 'https', label => 'https' },
   ],
   required => 1,
   element_class => ['input-small'],
   default => pf::Authentication::Source::HTTPSource->meta->get_attribute('protocol')->default,
  );
has_field 'username' =>
  (
   type => 'Text',
   label => 'API username (basic auth)',
  );
has_field 'password' =>
  (
   type => 'ObfuscatedText',
   label => 'API password (basic auth)',
   trim => undef,
  );
has_field 'authentication_url' =>
  (
   type => 'Text',
   label => 'Authentication URL',
   required => 1,
   tags => { after_element => \&help,
             help => 'Note : The URL is always prefixed by a slash (/)' },
  );
has_field 'authorization_url' =>
  (
   type => 'Text',
   label => 'Authorization URL',
   required => 1,
   tags => { after_element => \&help,
             help => 'Note : The URL is always prefixed by a slash (/)' },
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
