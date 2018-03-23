package pf::dal::_a3_entitlement;

=head1 NAME

pf::dal::_a3_entitlement - pf::dal implementation for the table a3_entitlement

=cut

=head1 DESCRIPTION

pf::dal::_a3_entitlement

pf::dal implementation for the table a3_entitlement

=cut

use strict;
use warnings;

###
### pf::dal::_a3_entitlement is auto generated any change to this file will be lost
### Instead change in the pf::dal::a3_entitlement module
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
        entitlement_key
        type
        status
        endpoint_count
        sub_start
        sub_end
        support_start
        support_end
    );

    %DEFAULTS = (
        entitlement_key => '',
        type => '',
        status => '',
        endpoint_count => '',
        sub_start => '',
        sub_end => '',
        support_start => '',
        support_end => '',
    );

    @INSERTABLE_FIELDS = qw(
        entitlement_key
        type
        status
        endpoint_count
        sub_start
        sub_end
        support_start
        support_end
    );

    %FIELDS_META = (
        entitlement_key => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 1,
            is_nullable => 0,
        },
        type => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        status => {
            type => 'INT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        endpoint_count => {
            type => 'INT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        sub_start => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        sub_end => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        support_start => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        support_end => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
    );

    @PRIMARY_KEYS = qw(
        entitlement_key
    );

    @COLUMN_NAMES = qw(
        a3_entitlement.entitlement_key
        a3_entitlement.type
        a3_entitlement.status
        a3_entitlement.endpoint_count
        a3_entitlement.sub_start
        a3_entitlement.sub_end
        a3_entitlement.support_start
        a3_entitlement.support_end
    );

}

use Class::XSAccessor {
    accessors => \@FIELD_NAMES,
};

=head2 _defaults

The default values of a3_entitlement

=cut

sub _defaults {
    return {%DEFAULTS};
}

=head2 field_names

Field names of a3_entitlement

=cut

sub field_names {
    return [@FIELD_NAMES];
}

=head2 primary_keys

The primary keys of a3_entitlement

=cut

sub primary_keys {
    return [@PRIMARY_KEYS];
}

=head2

The table name

=cut

sub table { "a3_entitlement" }

our $FIND_SQL = do {
    my $where = join(", ", map { "$_ = ?" } @PRIMARY_KEYS);
    "SELECT * FROM `a3_entitlement` WHERE $where;";
};

=head2 find_columns

find_columns

=cut

sub find_columns {
    return [@COLUMN_NAMES];
}

=head2 _find_one_sql

The precalculated sql to find a single row a3_entitlement

=cut

sub _find_one_sql {
    return $FIND_SQL;
}

=head2 _updateable_fields

The updateable fields for a3_entitlement

=cut

sub _updateable_fields {
    return [@FIELD_NAMES];
}

=head2 _insertable_fields

The insertable fields for a3_entitlement

=cut

sub _insertable_fields {
    return [@INSERTABLE_FIELDS];
}

=head2 get_meta

Get the meta data for a3_entitlement

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
