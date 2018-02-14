package pf::condition::false;
=head1 NAME

pf::condition::false

=cut

=head1 DESCRIPTION

pf::condition::false

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use pf::constants;

=head2 match

Always false

=cut

sub match { $FALSE }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

