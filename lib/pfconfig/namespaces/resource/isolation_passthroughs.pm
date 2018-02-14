package pfconfig::namespaces::resource::isolation_passthroughs;

=head1 NAME

pfconfig::namespaces::resource::isolation_passthroughs

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::isolation_passthroughs

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource::passthroughs';

=head2 build

Build the passthroughs hash

    {
        # All the non-wildcard passthroughs
        normal => {
            "example.com" => ["tcp:80", ...],
            ...
        },
        wildcard => {
            "wild.example.com" => ["tcp:80", ...],
            ...
        }

    }

=cut

sub build {
    my ($self) = @_;

    my @all_passthroughs = (
        @{$self->{config}->{fencing}->{isolation_passthroughs} // []},
    );

    return $self->_build(\@all_passthroughs);
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

