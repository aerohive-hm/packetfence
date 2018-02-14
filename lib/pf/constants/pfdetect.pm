package pf::constants::pfdetect;

=head1 NAME

pf::constants::pfdetect - constants for pfdetect object

=cut

=head1 DESCRIPTION

pf::constants::pfdetect

=cut

use strict;
use warnings;

use Module::Pluggable
  search_path => 'pf::detect::parser',
  sub_name    => '_modules',
  inner       => 0,
  require     => 1;

sub modules {
  my ($class) = @_;
  return map { (split('::', $_))[-1] } $class->_modules;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

