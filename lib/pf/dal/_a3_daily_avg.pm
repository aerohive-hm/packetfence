package pf::dal::_a3_daily_avg;

=head1 NAME

pf::dal::_a3_daily_avg - pf::dal implementation for the table a3_daily_avg

=cut

=head1 DESCRIPTION

pf::dal::_a3_daily_avg

pf::dal implementation for the table a3_daily_avg

=cut

use strict;
use warnings;

###
### pf::dal::_a3_daily_avg is auto generated any change to this file will be lost
### Instead change in the pf::dal::a3_daily_avg module
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
        daily_date
        daily_avg
        moving_avg
    );

    %DEFAULTS = (
        daily_date => '',
        daily_avg => '',
        moving_avg => '',
    );

    @INSERTABLE_FIELDS = qw(
        daily_date
        daily_avg
        moving_avg
    );

    %FIELDS_META = (
        daily_date => {
            type => 'DATE',
            is_auto_increment => 0,
            is_primary_key => 1,
            is_nullable => 0,
        },
        daily_avg => {
            type => 'INT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        moving_avg => {
            type => 'INT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
    );

    @PRIMARY_KEYS = qw(
        daily_date
    );

    @COLUMN_NAMES = qw(
        a3_daily_avg.daily_date
        a3_daily_avg.daily_avg
        a3_daily_avg.moving_avg
    );

}

use Class::XSAccessor {
    accessors => \@FIELD_NAMES,
};

=head2 _defaults

The default values of a3_daily_avg

=cut

sub _defaults {
    return {%DEFAULTS};
}

=head2 table_field_names

Field names of a3_daily_avg

=cut

sub table_field_names {
    return [@FIELD_NAMES];
}

=head2 primary_keys

The primary keys of a3_daily_avg

=cut

sub primary_keys {
    return [@PRIMARY_KEYS];
}

=head2

The table name

=cut

sub table { "a3_daily_avg" }

our $FIND_SQL = do {
    my $where = join(", ", map { "$_ = ?" } @PRIMARY_KEYS);
    "SELECT * FROM `a3_daily_avg` WHERE $where;";
};

=head2 find_columns

find_columns

=cut

sub find_columns {
    return [@COLUMN_NAMES];
}

=head2 _find_one_sql

The precalculated sql to find a single row a3_daily_avg

=cut

sub _find_one_sql {
    return $FIND_SQL;
}

=head2 _updateable_fields

The updateable fields for a3_daily_avg

=cut

sub _updateable_fields {
    return [@FIELD_NAMES];
}

=head2 _insertable_fields

The insertable fields for a3_daily_avg

=cut

sub _insertable_fields {
    return [@INSERTABLE_FIELDS];
}

=head2 get_meta

Get the meta data for a3_daily_avg

=cut

sub get_meta {
    return \%FIELDS_META;
}

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
