package pf::dal::person;

=head1 NAME

pf::dal::person - pf::dal module to override for the table person

=cut

=head1 DESCRIPTION

pf::dal::person

pf::dal implementation for the table person

=cut

use strict;
use warnings;

use base qw(pf::dal::_person);

my @PASSWORD_FIELDS = qw(
    password
    valid_from
    expiration
    access_duration
    access_level
    unregdate
    login_remaining
);

our @COLUMN_NAMES = (
    (map {"person.$_|$_"} @pf::dal::_person::FIELD_NAMES),
    (map {"password.$_|$_"} @PASSWORD_FIELDS),
    'password.sponsor|can_sponsor',
    'node_category.name|category',
);

use Class::XSAccessor {
# The getters for current location log entries
    getters   => [@PASSWORD_FIELDS, qw(can_sponsor)],
};

=head2 find_from_tables

Join the node_category table information in the node results

=cut

sub find_from_tables {
    [-join => qw(person =>{person.pid=password.pid} password =>{node_category.category_id=password.category} node_category)],
}

=head2 find_columns

Override the standard field names for node

=cut

sub find_columns {
    [@COLUMN_NAMES]
}

sub to_hash_fields {
    return [@pf::dal::_person::FIELD_NAMES, @PASSWORD_FIELDS, qw(can_sponsor nodes category)];
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
