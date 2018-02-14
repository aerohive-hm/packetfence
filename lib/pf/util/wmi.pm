package pf::util::wmi;

=head1 NAME

pf::util::wmi - utilities for wmi

=cut

=head1 DESCRIPTION

pf::util::wmi

=cut

use strict;
use warnings;

=head2 parse_wmi_response

=cut

sub parse_wmi_response {
    my ($response, $delimiter) = @_;
    $delimiter //= '|';
    $response =~ s/\r\n/\n/g;
    my ($class_header, $row_header, @rows) = split /\n/, $response;
    my $regex = qr/\Q$delimiter\E/;
    my @fields = split $regex, $row_header;
    my @results;
    foreach my $row (@rows) {
        my %data;
        @data{@fields} = split /\Q$delimiter\E/, $row;
        push @results, \%data;
    }
    return \@results;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
