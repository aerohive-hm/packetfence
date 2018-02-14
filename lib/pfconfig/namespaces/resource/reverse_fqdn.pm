package pfconfig::namespaces::resource::reverse_fqdn;

=head1 NAME

pfconfig::namespaces::resource::reverse_fqdn

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::reverse_fqdn

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;

    # we depend on the switch configuration object (russian doll style)
    $self->{fqdn} = $self->{cache}->get_cache('resource::fqdn');
}

sub build {
    my ($self) = @_;

    my $fqdn = $self->{fqdn};
    my @parts = split /\./, $fqdn;
    @parts = reverse @parts;
    my $reverse_fqdn = join '.', @parts;

    return $reverse_fqdn;
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

