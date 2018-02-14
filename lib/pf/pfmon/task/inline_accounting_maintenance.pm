package pf::pfmon::task::inline_accounting_maintenance;

=head1 NAME

pf::pfmon::task::inline_accounting_maintenance - class for pfmon task inline accounting maintenance

=cut

=head1 DESCRIPTION

pf::pfmon::task::inline_accounting_maintenance

=cut

use strict;
use warnings;
use pf::inline::accounting;
use pf::config qw(%Config);
use pf::util qw(isenabled);
use Moose;
extends qw(pf::pfmon::task);


=head2 run

run the inline accounting maintenance task

=cut

sub run {
    inline_accounting_maintenance( $Config{'inline'}{'layer3_accounting_session_timeout'} ) if isenabled($Config{'inline'}{'accounting'});
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
