package pfappserver::Form::Config::Source::Kickbox;

=head1 NAME

pfappserver::Form::Config::Source::Kickbox

=cut

=head1 DESCRIPTION

Form definition to create or update a Kickbox user source.

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';

# Form fields
has_field 'api_key' =>
  (
   type => 'Text',
   label => 'API KEY',
   required => 1,
   # Default value needed for creating dummy source
   default => '',
   tags => { after_element => \&help,
             help => 'Kickbox.io API key.' },
  );

has_field 'email_required' =>
  (
   type => 'Hidden',
   default => 'yes',
  );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

