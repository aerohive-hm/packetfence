package pf::constants::IP;

=head1 NAME

pf::constants::IP

=cut

=head1 DESCRIPTION

IP related constants

=cut

use strict;
use warnings;

use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw(
    $IPV4
    $IPV6
);


Readonly our $IPV4 => 'ipv4';
Readonly our $IPV6 => 'ipv6';


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

