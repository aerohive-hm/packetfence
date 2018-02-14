package pf::SearchBuilder::Node;

=head1 NAME

pf::SearchBuilder::Node -

=cut

=head1 DESCRIPTION

pf::SearchBuilder::Node

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::SearchBuilder);

sub sql_count {
    my $self = shift;
    return (
        join q{ },
        $self->select_count_clause(),
        "from (",
            $self->select_clause(),
            $self->from_clause(),
            $self->where_clause(),
            $self->group_by_clause(),
            $self->having_clause(),
        ") AS x"
    ) if($self->has_group_by_clause_elements);

    return (
        join q{ },
        $self->select_count_clause(),
        $self->count_from_clause(),
        $self->where_clause(),
    );
}

sub count_from_clause {
    my ($self,@args) = @_;
    my $sql = '';
    if($self->has_from_clause_elements){
        $sql = join(' ','FROM', map {  $self->format_from($_) } $self->first_from_clause_element);
    }
    return $sql;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

