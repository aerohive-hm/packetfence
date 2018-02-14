package pf::dal::_inline_accounting;

=head1 NAME

pf::dal::_inline_accounting - pf::dal implementation for the table inline_accounting

=cut

=head1 DESCRIPTION

pf::dal::_inline_accounting

pf::dal implementation for the table inline_accounting

=cut

use strict;
use warnings;

###
### pf::dal::_inline_accounting is auto generated any change to this file will be lost
### Instead change in the pf::dal::inline_accounting module
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
        outbytes
        inbytes
        ip
        firstseen
        lastmodified
        status
    );

    %DEFAULTS = (
        outbytes => '0',
        inbytes => '0',
        ip => '',
        firstseen => '',
        lastmodified => '',
        status => '0',
    );

    @INSERTABLE_FIELDS = qw(
        outbytes
        inbytes
        ip
        firstseen
        lastmodified
        status
    );

    %FIELDS_META = (
        outbytes => {
            type => 'BIGINT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        inbytes => {
            type => 'BIGINT',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        ip => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 1,
            is_nullable => 0,
        },
        firstseen => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 1,
            is_nullable => 0,
        },
        lastmodified => {
            type => 'DATETIME',
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
    );

    @PRIMARY_KEYS = qw(
        ip
        firstseen
    );

    @COLUMN_NAMES = qw(
        inline_accounting.outbytes
        inline_accounting.inbytes
        inline_accounting.ip
        inline_accounting.firstseen
        inline_accounting.lastmodified
        inline_accounting.status
    );

}

use Class::XSAccessor {
    accessors => \@FIELD_NAMES,
};

=head2 _defaults

The default values of inline_accounting

=cut

sub _defaults {
    return {%DEFAULTS};
}

=head2 field_names

Field names of inline_accounting

=cut

sub field_names {
    return [@FIELD_NAMES];
}

=head2 primary_keys

The primary keys of inline_accounting

=cut

sub primary_keys {
    return [@PRIMARY_KEYS];
}

=head2

The table name

=cut

sub table { "inline_accounting" }

our $FIND_SQL = do {
    my $where = join(", ", map { "$_ = ?" } @PRIMARY_KEYS);
    "SELECT * FROM `inline_accounting` WHERE $where;";
};

=head2 find_columns

find_columns

=cut

sub find_columns {
    return [@COLUMN_NAMES];
}

=head2 _find_one_sql

The precalculated sql to find a single row inline_accounting

=cut

sub _find_one_sql {
    return $FIND_SQL;
}

=head2 _updateable_fields

The updateable fields for inline_accounting

=cut

sub _updateable_fields {
    return [@FIELD_NAMES];
}

=head2 _insertable_fields

The insertable fields for inline_accounting

=cut

sub _insertable_fields {
    return [@INSERTABLE_FIELDS];
}

=head2 get_meta

Get the meta data for inline_accounting

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
