package pf::provisioner::android;
=head1 NAME

pf::provisioner::android add documentation

=cut

=head1 DESCRIPTION

pf::provisioner::android

=cut

use strict;
use warnings;
use Moo;
extends 'pf::provisioner::mobileconfig';
use fingerbank::Constant;

=head1 Atrributes

=head2 oses

The set the default OS Andriod

=cut

# Will always ignore the oses parameter provided and use [Generic Android]
has 'oses' => (is => 'ro', default => sub { [$fingerbank::Constant::PARENT_IDS{ANDROID}] }, coerce => sub { [$fingerbank::Constant::PARENT_IDS{ANDROID}] });

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
