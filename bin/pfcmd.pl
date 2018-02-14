#!/usr/bin/perl -T
=head1 NAME

pfcmd

=cut

=head1 DESCRIPTION

driver script for pfcmd

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);

# force UID/EUID to root to allow socket binds, etc
# required for non-root (and GUI) service restarts to work
$> = 0;
$< = 0;

# To ensure group permissions are properly added
umask(0007);

use pf::cmd::pf;
exit pf::cmd::pf->new({args => \@ARGV})->run();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut
