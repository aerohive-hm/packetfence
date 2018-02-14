package pf::detect::parser::fortianalyser;
=head1 NAME

pf::detect::parser::fortianalyser

=cut

=head1 DESCRIPTION

pf::detect::parser::fortianalyser

Class to parse syslog from a Fortianalyser

=cut

use strict;
use warnings;
use Moo;
extends qw(pf::detect::parser);

sub parse {
    my ($self,$line) = @_;

    my $data = {};
    my @fields = (); my %fields = (); 
    @fields = grep  /\=/ ,  split( /\s+/, $line );
    %fields = map { split /\=/ } @fields;

    return { srcip => $fields{srcip}, events => { detect => $fields{logid} } };
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

