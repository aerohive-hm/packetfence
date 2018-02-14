package pfconfig::namespaces::resource::switches_ranges;

=head1 NAME

pfconfig::namespaces::resource::switches_ranges

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::switches_ranges

This module creates the configuration hash of all the switches ranges (ex : 192.168.1.0/24)

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

use NetAddr::IP;

sub init {
    my ($self) = @_;
    # we depend on the switch configuration object (russian doll style)
    $self->{switches} = $self->{cache}->get_cache('config::Switch');
}

sub build {
    my ($self) = @_;
    my @ranges;
    foreach my $switch ( keys %{$self->{switches}} ) {
        my $network = NetAddr::IP->new($switch);
        next if (!defined($network) || ($network->num eq 1) || $switch eq "default");
        push @ranges,[$network,$switch];
    }
    my @ordered_ranges = sort { $b->[0]->masklen <=> $a->[0]->masklen } @ranges ;
    return \@ordered_ranges;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

