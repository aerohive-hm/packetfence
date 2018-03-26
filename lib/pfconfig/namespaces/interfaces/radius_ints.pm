package pfconfig::namespaces::interfaces::radius_ints;

=head1 NAME

pfconfig::namespaces::interfaces::radius_ints

=cut

=head1 DESCRIPTION

Return all the interfaces where radius must run

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::interfaces';

sub init {
    my ($self, $host_id) = @_;
    $self->{_interfaces} = defined($host_id) ? $self->{cache}->get_cache("interfaces($host_id)") : $self->{cache}->get_cache("interfaces");
}

sub build {
    my ($self) = @_;
    my $interfaces = $self->{_interfaces};
    my $mn = $interfaces->{management_network};
    push @{ $interfaces->{radius_ints} }, $mn if $mn;
    return $interfaces->{radius_ints} // [];
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

