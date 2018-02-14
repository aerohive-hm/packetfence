package pf::dal::activation;

=head1 NAME

pf::dal::activation - pf::dal module to override for the table activation

=cut

=head1 DESCRIPTION

pf::dal::activation

pf::dal implementation for the table activation

=cut

use strict;
use warnings;

use base qw(pf::dal::_activation);

our @COLUMN_NAMES = (
    (map {"activation.$_|$_"} @pf::dal::_activation::FIELD_NAMES),
    'sms_carrier.email_pattern|carrier_email_pattern',
);

use Class::XSAccessor {
    getters => [qw(carrier_email_pattern)]
};

=head2 find_from_tables

Join the node_category table information in the node results

=cut

sub find_from_tables {
    [-join => qw(activation =>{sms_carrier.id=activation.carrier_id} sms_carrier)]
}

=head2 find_columns

Override the standard field names for activation

=cut

sub find_columns {
    [@COLUMN_NAMES]
}

=head2 to_hash_fields

to_hash_fields

=cut

sub to_hash_fields {
    return [@pf::dal::_activation::FIELD_NAMES, 'carrier_email_pattern']
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
