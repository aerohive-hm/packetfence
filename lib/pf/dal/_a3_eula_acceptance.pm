package pf::dal::_a3_eula_acceptance;

=head1 NAME

pf::dal::_a3_eula_acceptance - pf::dal implementation for the table a3_eula_acceptance

=cut

=head1 DESCRIPTION

pf::dal::_a3_eula_acceptance

pf::dal implementation for the table a3_eula_acceptance

=cut

use strict;
use warnings;

###
### pf::dal::_a3_eula_acceptance is auto generated any change to this file will be lost
### Instead change in the pf::dal::a3_eula_acceptance module
###

use base qw(pf::dal);

our @FIELD_NAMES;
our @INSERTABLE_FIELDS;
our @PRIMARY_KEYS;
our %DEFAULTS;
our %FIELDS_META;
our @COLUMN_NAMES;

BEGIN {
    @FIELD_NAMES = qw(
        timestamp
        is_synced
    );

    %DEFAULTS = (
        timestamp => '',
        is_synced => '',
    );

    @INSERTABLE_FIELDS = qw(
        timestamp
        is_synced
    );

    %FIELDS_META = (
        timestamp => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 1,
            is_nullable => 0,
        },
        is_synced => {
            type => 'TINYINT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
    );

    @PRIMARY_KEYS = qw(
        timestamp
    );

    @COLUMN_NAMES = qw(
        a3_eula_acceptance.timestamp
        a3_eula_acceptance.is_synced
    );

}

use Class::XSAccessor {
    accessors => \@FIELD_NAMES,
};

=head2 _defaults

The default values of a3_eula_acceptance

=cut

sub _defaults {
    return {%DEFAULTS};
}

=head2 field_names

Field names of a3_eula_acceptance

=cut

sub field_names {
    return [@FIELD_NAMES];
}

=head2 primary_keys

The primary keys of a3_eula_acceptance

=cut

sub primary_keys {
    return [@PRIMARY_KEYS];
}

=head2

The table name

=cut

sub table { "a3_eula_acceptance" }

our $FIND_SQL = do {
    my $where = join(", ", map { "$_ = ?" } @PRIMARY_KEYS);
    "SELECT * FROM `a3_eula_acceptance` WHERE $where;";
};

=head2 find_columns

find_columns

=cut

sub find_columns {
    return [@COLUMN_NAMES];
}

=head2 _find_one_sql

The precalculated sql to find a single row a3_eula_acceptance

=cut

sub _find_one_sql {
    return $FIND_SQL;
}

=head2 _updateable_fields

The updateable fields for a3_eula_acceptance

=cut

sub _updateable_fields {
    return [@FIELD_NAMES];
}

=head2 _insertable_fields

The insertable fields for a3_eula_acceptance

=cut

sub _insertable_fields {
    return [@INSERTABLE_FIELDS];
}

=head2 get_meta

Get the meta data for a3_eula_acceptance

=cut

sub get_meta {
    return \%FIELDS_META;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
