package pfappserver::Form::AdvancedSearch;

=head1 NAME

pfappserver::Form::Node - Web form for a node
pfappserver::Form::Search::Node - Web form for searching Nodes

=head1 DESCRIPTION

Form definition to create or update a node.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';

=head2 Form Fields

=over

=item start

=cut

has_field 'start' =>
  (
   type => 'DatePicker',
  );

=item end

=cut

has_field 'end' =>
  (
   type => 'DatePicker',
  );

=item page_num

=cut

has_field 'page_num' =>
  (
   type => 'Hidden',
   default => '1',
  );

=item per_page

=cut

has_field 'per_page' =>
  (
   type => 'Hidden',
   default => '25',
   input_without_param => 25,
  );

=item by

=cut

has_field 'by' =>
  (
   type => 'Hidden',
  );

=item direction

=cut

has_field 'direction' =>
  (
   type => 'Hidden',
   default => 'asc',
  );

=item all_or_any

=cut

has_field 'all_or_any' =>
  (
   type => 'Select',
   options => [
    { value => 'all', label => 'All' },
    { value => 'any', label => 'Any' },
   ]
  );


=item end

=cut

has_field 'searches' =>
  (
   type => 'Repeatable',
   num_when_empty => 0,
  );

=item end

=cut

has_field 'searches.name' =>
  (
   type => 'Text',
   do_label => 0,
  );

=item end

=cut

has_field 'searches.op' =>
  (
   type => 'Text',
   do_label => 0,
  );

=item end

=cut

has_field 'searches.value' =>
  (
   type => 'Text',
   do_label => 0,
  );

has_field 'filter' =>
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
