package pf::dal::_scan;

=head1 NAME

pf::dal::_scan - pf::dal implementation for the table scan

=cut

=head1 DESCRIPTION

pf::dal::_scan

pf::dal implementation for the table scan

=cut

use strict;
use warnings;

###
### pf::dal::_scan is auto generated any change to this file will be lost
### Instead change in the pf::dal::scan module
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
        id
        ip
        mac
        type
        start_date
        update_date
        status
        report_id
    );

    %DEFAULTS = (
        id => '',
        ip => '',
        mac => '',
        type => '',
        start_date => '',
        update_date => '0000-00-00 00:00:00',
        status => '',
        report_id => '',
    );

    @INSERTABLE_FIELDS = qw(
        id
        ip
        mac
        type
        start_date
        update_date
        status
        report_id
    );

    %FIELDS_META = (
        id => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 1,
            is_nullable => 0,
        },
        ip => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        mac => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        type => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        start_date => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        update_date => {
            type => 'TIMESTAMP',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        status => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        report_id => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
    );

    @PRIMARY_KEYS = qw(
        id
    );

    @COLUMN_NAMES = qw(
        scan.id
        scan.ip
        scan.mac
        scan.type
        scan.start_date
        scan.update_date
        scan.status
        scan.report_id
    );

}

use Class::XSAccessor {
    accessors => \@FIELD_NAMES,
};

=head2 _defaults

The default values of scan

=cut

sub _defaults {
    return {%DEFAULTS};
}

=head2 field_names

Field names of scan

=cut

sub field_names {
    return [@FIELD_NAMES];
}

=head2 primary_keys

The primary keys of scan

=cut

sub primary_keys {
    return [@PRIMARY_KEYS];
}

=head2

The table name

=cut

sub table { "scan" }

our $FIND_SQL = do {
    my $where = join(", ", map { "$_ = ?" } @PRIMARY_KEYS);
    "SELECT * FROM `scan` WHERE $where;";
};

=head2 find_columns

find_columns

=cut

sub find_columns {
    return [@COLUMN_NAMES];
}

=head2 _find_one_sql

The precalculated sql to find a single row scan

=cut

sub _find_one_sql {
    return $FIND_SQL;
}

=head2 _updateable_fields

The updateable fields for scan

=cut

sub _updateable_fields {
    return [@FIELD_NAMES];
}

=head2 _insertable_fields

The insertable fields for scan

=cut

sub _insertable_fields {
    return [@INSERTABLE_FIELDS];
}

=head2 get_meta

Get the meta data for scan

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
