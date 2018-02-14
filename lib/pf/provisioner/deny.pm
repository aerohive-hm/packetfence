package pf::provisioner::deny;
=head1 NAME

pf::provisioner::deny add documentation

=cut

=head1 DESCRIPTION

pf::provisioner::deny

=cut

use strict;
use warnings;
use List::MoreUtils qw(any);
use Moo;
extends 'pf::provisioner';


=head1 METHODS

=head2 authorize

never authorize user

=cut

sub authorize { 0 };

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

