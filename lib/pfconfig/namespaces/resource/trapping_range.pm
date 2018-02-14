package pfconfig::namespaces::resource::trapping_range;

=head1 NAME

pfconfig::namespaces::resource::trapping_range

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::trapping_range

This module creates the configuration hash of all the trapping range

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

use NetAddr::IP;

sub init {
    my ($self) = @_;
    $self->{config} = $self->{cache}->get_cache('config::Pf');
}

sub build {
    my ($self) = @_;
    my @ranges;
    foreach my $range (split(',',$self->{config}{'fencing'}{'range'})) {
        my $network = NetAddr::IP->new($range);
        push @ranges,$network;
    }
    return \@ranges;
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
