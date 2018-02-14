package pf::dal::_ip6log;

=head1 NAME

pf::dal::_ip6log - pf::dal implementation for the table ip6log

=cut

=head1 DESCRIPTION

pf::dal::_ip6log

pf::dal implementation for the table ip6log

=cut

use strict;
use warnings;

###
### pf::dal::_ip6log is auto generated any change to this file will be lost
### Instead change in the pf::dal::ip6log module
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
        mac
        ip
        type
        start_time
        end_time
    );

    %DEFAULTS = (
        mac => '',
        ip => '',
        type => undef,
        start_time => '',
        end_time => '0000-00-00 00:00:00',
    );

    @INSERTABLE_FIELDS = qw(
        mac
        ip
        type
        start_time
        end_time
    );

    %FIELDS_META = (
        mac => {
            type => 'VARCHAR',
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
        type => {
            type => 'VARCHAR',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 1,
        },
        start_time => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 0,
        },
        end_time => {
            type => 'DATETIME',
            is_auto_increment => 0,
            is_primary_key => 0,
            is_nullable => 1,
        },
    );

    @PRIMARY_KEYS = qw(
        ip
    );

    @COLUMN_NAMES = qw(
        ip6log.mac
        ip6log.ip
        ip6log.type
        ip6log.start_time
        ip6log.end_time
    );

}

use Class::XSAccessor {
    accessors => \@FIELD_NAMES,
};

=head2 _defaults

The default values of ip6log

=cut

sub _defaults {
    return {%DEFAULTS};
}

=head2 field_names

Field names of ip6log

=cut

sub field_names {
    return [@FIELD_NAMES];
}

=head2 primary_keys

The primary keys of ip6log

=cut

sub primary_keys {
    return [@PRIMARY_KEYS];
}

=head2

The table name

=cut

sub table { "ip6log" }

our $FIND_SQL = do {
    my $where = join(", ", map { "$_ = ?" } @PRIMARY_KEYS);
    "SELECT * FROM `ip6log` WHERE $where;";
};

=head2 find_columns

find_columns

=cut

sub find_columns {
    return [@COLUMN_NAMES];
}

=head2 _find_one_sql

The precalculated sql to find a single row ip6log

=cut

sub _find_one_sql {
    return $FIND_SQL;
}

=head2 _updateable_fields

The updateable fields for ip6log

=cut

sub _updateable_fields {
    return [@FIELD_NAMES];
}

=head2 _insertable_fields

The insertable fields for ip6log

=cut

sub _insertable_fields {
    return [@INSERTABLE_FIELDS];
}

=head2 get_meta

Get the meta data for ip6log

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
