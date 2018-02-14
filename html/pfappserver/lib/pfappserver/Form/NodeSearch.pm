package pfappserver::Form::NodeSearch;

=head1 NAME

pfappserver::Form::NodeSearch

=head1 DESCRIPTION

Web form for a searching a node

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::AdvancedSearch';

=head2 Form Fields

=over


=item online_date

=cut

has_field 'online_date' =>
  (
   type => 'Compound',
  );

=item online_date.start

=cut

has_field 'online_date.start' =>
  (
   type => 'DatePicker',
  );

=item end

=cut

has_field 'online_date.end' =>
  (
   type => 'DatePicker',
  );

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
