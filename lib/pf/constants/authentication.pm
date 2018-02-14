package pf::constants::authentication;

=head1 NAME

pf::constants::authentication - constants for authentication object

=cut

=head1 DESCRIPTION

pf::constants::authentication

=cut

use strict;
use warnings;

use Module::Pluggable
  'search_path' => [qw(pf::Authentication::Source)],
  'sub_name'    => 'sources',
  'require'     => 1,
  'inner'       => 0,
  ;

our @SOURCES = __PACKAGE__->sources();

our %TYPE_TO_SOURCE = map { lc($_->meta->get_attribute('type')->default) => $_ } @SOURCES;



=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

