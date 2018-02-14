package pfappserver::Form::UserSearch;

=head1 NAME

pfappserver::Form::UserSearch

=head1 DESCRIPTION

Web form for a searching a node

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::AdvancedSearch';


=head2 by

by

=cut

has_field 'by' =>
  (
   type => 'Text',
   default => 'person.pid',
  );


=head2 direction

direction

=cut

has_field 'direction' =>
  (
   type => 'Text',
   default => 'asc',
  );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
