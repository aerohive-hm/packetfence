package pf::dal::violation;

=head1 NAME

pf::dal::violation - pf::dal module to override for the table violation

=cut

=head1 DESCRIPTION

pf::dal::violation

pf::dal implementation for the table violation

=cut

use strict;
use warnings;

use base qw(pf::dal::_violation);
use Class::XSAccessor {
    getters => [qw(description)]
};

our @COLUMN_NAMES = (
    @pf::dal::_violation::COLUMN_NAMES,
    qw(class.description|description)
);

=head2 find_from_tables

Join the node_category table information in the node results

=cut

sub find_from_tables {
     [-join => qw(violation <=>{violation.vid=class.vid} class)]
}

=head2 find_columns

Override the standard field names for violation

=cut

sub find_columns {
    [@COLUMN_NAMES]
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
