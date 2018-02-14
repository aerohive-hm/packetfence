package pfappserver::View::Configurator;

use strict;
use warnings;

use Moose;
extends 'pfappserver::View::HTML';

__PACKAGE__->config(
    WRAPPER => 'configurator/wrapper.tt',
);

=head1 NAME

pfappserver::View::Configurator - HTML View for configurator

=head1 DESCRIPTION

TT View for configurator.

=head1 SEE ALSO

L<pfappserver>

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
