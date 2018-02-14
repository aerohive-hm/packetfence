package pfappserver::Base::Form::Role::WithCustomFields;

=head1 NAME

pfappserver::Base::Form::Role::WithCustomFields

=head1 DESCRIPTION

Role for portal modules with custom fields

=cut

use HTML::FormHandler::Moose::Role;
with 'pfappserver::Base::Form::Role::Help';

use pf::person;

## Definition
has_field 'custom_fields' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Mandatory fields',
   options_method => \&options_custom_fields,
   element_class => ['chzn-select'],
   element_attr => {'data-placeholder' => 'Click to add a required field'},
   tags => { after_element => \&help,
             help => 'The additionnal fields that should be required for registration' },
  );

sub options_custom_fields {
    return map {$_ => $_} @pf::person::PROMPTABLE_FIELDS;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


