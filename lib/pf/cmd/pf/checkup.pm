package pf::cmd::pf::checkup;
=head1 NAME

pf::cmd::pf::checkup

=head1 SYNOPSIS

pfcmd checkup

perform a sanity checkup and report any problems or warnings

=head1 DESCRIPTION

pf::cmd::checkup

=cut

use strict;
use warnings;
use pf::services;
use pf::constants;
use pf::constants::exit_code qw($EXIT_SUCCESS $EXIT_FAILURE $EXIT_FATAL);
use pf::pfcmd::checkup;
use base qw(pf::cmd);
sub _run {
    my ($self) = @_;
    my @problems = pf::pfcmd::checkup::sanity_check(pf::services::service_list(@pf::services::ALL_SERVICES));
    foreach my $entry (@problems) {
        chomp $entry->{$pf::pfcmd::checkup::MESSAGE};
        print $entry->{$pf::pfcmd::checkup::SEVERITY}  . " - " . $entry->{$pf::pfcmd::checkup::MESSAGE} . "\n";
    }

    # if there is a fatal problem, exit with status 255
    foreach my $entry (@problems) {
        if ($entry->{$pf::pfcmd::checkup::SEVERITY} eq $pf::pfcmd::checkup::FATAL) {
            return $EXIT_FATAL;
        }
    }

    if (@problems) {
        return $EXIT_FAILURE;
    } else {
        return $EXIT_SUCCESS;
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

