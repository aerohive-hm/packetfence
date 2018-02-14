package pf::IP;

=head1 NAME

pf::IP

=cut

=head1 DESCRIPTION

Base object class for handling / managing IP addresses

=cut

use strict;
use warnings;

use Moose;

# External libs

# Internal libs
use pf::log;


has 'normalizedIP'  => (is => 'rw');
has 'prefixLength'  => (is => 'rw', isa => 'Maybe[Int]');
has 'type'          => (is => 'rw', default => undef);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
