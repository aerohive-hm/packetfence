package pf::provisioner::accept;
=head1 NAME

pf::provisioner::accept add documentation

=cut

=head1 DESCRIPTION

pf::provisioner::accept

=cut

use strict;
use warnings;
use List::MoreUtils qw(any);
use Moo;
extends 'pf::provisioner';

=head1 METHODS

=head2 authorize

always authorize user

=cut

sub authorize { 1 };

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

