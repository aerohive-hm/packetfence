package pf::sms_carrier;

=head1 NAME

pf::sms_carrier add documentation

=cut

=head1 DESCRIPTION

pf::sms_carrier

=cut

use strict;
use warnings;
use pf::db;
use pf::log;
use pf::error qw(is_error);
use pf::dal::sms_carrier;

BEGIN {
    use Exporter ();
    our (@ISA, @EXPORT);
    @ISA    = qw(Exporter);
    @EXPORT = qw(sms_carrier_view_all sms_carrier_view);
}

=head1 SUBROUTINES

=head2 sms_carrier_view_all

=cut

sub sms_carrier_view_all {
    my $source = shift;
    # Check if a SMS authentication source is defined; if so, use the carriers list
    # from this source
    my %search = (
            -columns => [qw(id name)]
    );
    if ($source) {
        $search{-where} = {
            id => $source->{'sms_carriers'}
        };
    }
    my ($status, $iter) = pf::dal::sms_carrier->search(%search);
    return [] if is_error($status);
    my $val = $iter->all(undef);

    return $val;
}

=head2 sms_carrier_view

=cut

sub sms_carrier_view {
    my $id = shift;
    my ($status, $item) = pf::dal::sms_carrier->find({id=>$id});
    if (is_error($status)) {
        return (0);
    }
    return ($item->to_hash());
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

