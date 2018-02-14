package pf::factory::report;

=head1 NAME

pf::factory::report

=cut

=head1 DESCRIPTION

The factory for reports

=cut

use strict;
use warnings;

use List::MoreUtils qw(any);
use pf::Report;

use pf::config qw(%ConfigReport);

sub factory_for { 'pf::Report' }

=head2 new

Will create a new pf::report sub class  based off the name of the provider
If no provider is found the return undef

=cut

sub new {
    my ($class,$id) = @_;
    my $report;
    my $data = $ConfigReport{$id};
    if ($data) {
        $data->{id} = $id;
        $report = factory_for->new($data);
    }
    return $report;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


