package pf::factory::survey;

=head1 NAME

pf::factory::survey

=cut

=head1 DESCRIPTION

The factory for surveys

=cut

use strict;
use warnings;

use List::MoreUtils qw(any);
use pf::Survey;

use pf::config qw(%ConfigSurvey);

sub factory_for { 'pf::Survey' }

=head2 new

Will create a new pf::survey sub class  based off the name of the provider
If no provider is found the return undef

=cut

sub new {
    my ($class,$id) = @_;
    my $survey;
    my $data = $ConfigSurvey{$id};
    if ($data) {
        $data->{id} = $id;
        $survey = factory_for->new($data);
    }
    return $survey;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



