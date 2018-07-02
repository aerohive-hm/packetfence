package pfappserver::Form::Portal;

=head1 NAME

pfappserver::Form::Portal - connection profiles

=head1 DESCRIPTION

Sortable list of connection profiles.

=cut

use HTML::FormHandler::Moose;

extends 'pfappserver::Base::Form';


=head2 Form fields

=over

=item items

=cut

has_field 'items' =>
  (
   type => 'Repeatable',
   num_when_empty => 0,
  );

=item items.id

=cut

has_field 'items.id' =>
  (
   type => 'Hidden',
   do_label => 0,
  );

=item items.description

=cut

has_field 'items.description' =>
  (
   type => 'Text',
   do_label => 0,
  );

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
