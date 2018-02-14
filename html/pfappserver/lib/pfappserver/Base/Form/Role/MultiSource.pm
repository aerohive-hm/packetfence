package pfappserver::Base::Form::Role::MultiSource;

=head1 NAME

pfappserver::Base::Form::Role::MultiSource

=head1 DESCRIPTION

Role for MultiSource portal modules

=cut

use HTML::FormHandler::Moose::Role;
with 'pfappserver::Base::Form::Role::Help';

has_field 'multi_source_object_classes' =>
  (
   type => 'TextArea',
   label => 'Sources by Class',
   element_class => ['input-xxlarge'],
   required => 0,
   tags => { after_element => \&help,
             help => 'The sources inheriting from these classes and part of the connection profile will be added to the available sources' },
  );

has_field 'multi_source_types' => 
  (
   type => 'TextArea',
   element_class => ['input-xxlarge'],
   label => 'Sources by type',
   required => 0,
   tags => { after_element => \&help,
             help => 'The sources of these types and part of the connection profile will be added to the available sources' },
  );

has_field 'multi_source_auth_classes' => 
  (
   type => 'TextArea',
   label => 'Sources by Auth Class',
   element_class => ['input-xxlarge'],
   required => 0,
   tags => { after_element => \&help,
             help => 'The sources of these authentication classes and part of the connection profile will be added to the available sources' },
  );

has_block 'multi_source_definition' => (
    render_list => [qw(multi_source_object_classes multi_source_types multi_source_auth_classes)],
);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

