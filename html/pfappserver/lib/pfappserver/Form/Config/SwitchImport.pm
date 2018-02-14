package pfappserver::Form::Config::SwitchImport;

=head1 NAME

pfappserver::Form::Config::SwitchImport - Web form for switch import

=head1 DESCRIPTION

Form for importing switches from a CSV file

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

#import from CSV
has_field importcsv =>
  (
    type => 'Upload',
    label => 'CSV file',
    required => 1,
  );

has_field 'delimiter' =>
  (
   type => 'Select',
   label => 'Column Delimiter',
   required => 1,
   options =>
   [
    { value => 'comma', label => 'Comma' },
    { value => 'semicolon', label => 'Semicolon' },
    { value => 'colon', label => 'Colon' },
    { value => 'tab', label => 'Tab' },
   ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
