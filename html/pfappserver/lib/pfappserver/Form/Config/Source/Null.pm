package pfappserver::Form::Config::Source::Null;

=head1 NAME

pfappserver::Form::Config::Source::Null

=cut

=head1 DESCRIPTION

Form definition to create or update a Null authentication source.

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';

# Form fields
has_field 'email_required' =>
  (
   type => 'Toggle',
   checkbox_value => 'yes',
   unchecked_value => 'no',
  );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
