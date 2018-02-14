package pf::factory::task;

=head1 NAME

pf::factory::task

=cut

=head1 DESCRIPTION

pf::factory::task

=cut

use strict;
use warnings;
use Module::Pluggable
  search_path => 'pf::task',
  sub_name    => 'modules',
  inner       => 0,
  require     => 1;
use List::MoreUtils qw(any);

our @MODULES = __PACKAGE__->modules;

sub factory_for { 'pf::task' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

