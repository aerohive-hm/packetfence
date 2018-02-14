package pf::pfqueue::producer;

=head1 NAME

pf::pfqueue::producer - Base class for pf::pfqueue::producer

=cut

=head1 DESCRIPTION

pf::pfqueue::producer

=cut

use strict;
use warnings;
use Moo;

=head2 submit

Submit a task to the queue

=cut

sub submit {
    die "submit Not implemented";
}

=head2 submit_delayed

Submit a task to the queue but delayed

=cut

sub submit_delayed {
    die "delayed Not implemented";
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
