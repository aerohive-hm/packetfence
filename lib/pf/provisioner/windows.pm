package pf::provisioner::windows;
=head1 NAME

pf::provisioner::windows add documentation

=cut

=head1 DESCRIPTION

pf::provisioner::windows

=cut

use strict;
use warnings;
use Moo;
extends 'pf::provisioner::mobileconfig';
use fingerbank::Constant;

=head1 Atrributes

=head2 oses

The set the default Windows OS

=cut

# Will always ignore the oses parameter provided and use [Windows]
has 'oses' => (is => 'ro', default => sub { [$fingerbank::Constant::PARENT_IDS{WINDOWS}] }, coerce => sub { [$fingerbank::Constant::PARENT_IDS{WINDOWS}] });

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1
