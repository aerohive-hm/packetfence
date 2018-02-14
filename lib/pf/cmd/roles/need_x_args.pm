package pf::cmd::roles::need_x_args;
=head1 NAME

pf::cmd::roles::need_x_args add documentation

=cut

=head1 DESCRIPTION

pf::cmd::roles::need_x_args

=cut

use strict;
use warnings;
use Role::Tiny;

requires qw(numberOfArgs);

sub parseArgs {
    $_[0]->args == $_[0]->numberOfArgs
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

