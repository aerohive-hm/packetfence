package pf::dal::class;

=head1 NAME

pf::dal::class - pf::dal module to override for the table class

=cut

=head1 DESCRIPTION

pf::dal::class

pf::dal implementation for the table class

=cut

use strict;
use warnings;

use base qw(pf::dal::_class);
use Class::XSAccessor {
    getters => [qw(action)],
};

sub find_from_tables {
    [-join => qw(class =>{class.vid=action.vid} action)],
}

our @COLUMN_NAMES = (
    (map {"class.$_|$_"} @pf::dal::_class::FIELD_NAMES),
    'group_concat(action.action order by action.action asc)|action'
);


=head2 find_select_args

find_select_args

=cut

sub find_select_args {
    my ($self, @args) = @_;
    my $select_args = $self->SUPER::find_select_args(@args);
    $select_args->{'-group_by'} = 'class.vid';
    return $select_args;
}

=head2 find_columns

Override the standard field names for node

=cut

sub find_columns {
    [@COLUMN_NAMES]
}

=head2 to_hash_fields

to_hash_fields

=cut

sub to_hash_fields {
    return [@pf::dal::_class::FIELD_NAMES, qw(action)];
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
