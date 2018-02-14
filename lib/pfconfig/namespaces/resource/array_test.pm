package pfconfig::namespaces::resource::array_test;

=head1 NAME

pfconfig::namespaces::resource::array_test

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::array_test

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub build {
    my ($self) = @_;
    return [ "first", "second", "third" ];
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

