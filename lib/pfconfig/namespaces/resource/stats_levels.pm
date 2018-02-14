package pfconfig::namespaces::resource::stats_levels;

=head1 NAME

pfconfig::namespaces::resource::stats_levels

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::stats_levels

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;

    $self->{config}         = $self->{cache}->get_cache('config::Pf');
}

sub build {
    my ($self) = @_;

    return { timing => $self->{config}->{advanced}->{timing_stats_level} };
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


