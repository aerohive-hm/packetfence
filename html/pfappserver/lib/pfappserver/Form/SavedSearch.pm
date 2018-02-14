package pfappserver::Form::SavedSearch;

=head1 NAME

pfappserver::Form::SavedSearch

=cut

=head1 DESCRIPTION

Form for SavedSearch data

=cut

use HTML::FormHandler::Moose;

extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

=head1 Fields

=cut

=head2 name

=cut

has_field 'name'  => (
   type  => 'Text',
   label => 'Name',
   tags  => { after_element => \&help,
             help => 'Your saved search will appear in the menu on the left side of your screen.'
    },
);

=head2 query

=cut

has_field 'query' => (
   type => 'Hidden',
);

=head2 pid

=cut

has_field 'pid' => (
   type => 'Text',
   widget => 'NoRender',
);

=head2 namespace

=cut

has_field 'namespace' => (
   type => 'Text',
   widget => 'NoRender',
);

=head1 Blocks

=head2 search

=cut

has_block 'search' =>
  (
   render_list => [qw(name query)],
  );


=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};



=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

