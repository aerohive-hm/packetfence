package pf::provisioner::dpsk;
=head1 NAME

pf::provisioner::dpsk allow to have a html page that present the psk and the ssid to use


=cut

=head1 DESCRIPTION

pf::provisioner::dpsk

=cut

use strict;
use warnings;
use List::MoreUtils qw(any);
use Crypt::GeneratePassword qw(word);
use pf::person;

use Moo;
extends 'pf::provisioner::mobileconfig';


=head1 METHODS

=head2 authorize

never authorize user

=cut

sub authorize { 0 };

=head2 oses

The oses

=cut

has oses => (is => 'rw');

=head2 ssid

The ssid broadcast name

=cut

has ssid => (is => 'rw');

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

