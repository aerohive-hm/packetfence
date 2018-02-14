package pf::condition::true;
=head1 NAME

pf::condition::true

=cut

=head1 DESCRIPTION

pf::condition::true

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);
use pf::constants;

=head2 match

Always return true

=cut

sub match { $TRUE }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

