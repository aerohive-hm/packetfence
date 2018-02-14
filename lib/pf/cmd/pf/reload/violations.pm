package pf::cmd::pf::reload::violations;
=head1 NAME

pf::cmd::pf::reload::violations add documentation

=cut

=head1 DESCRIPTION

pf::cmd::pf::reload::violations

=cut

use strict;
use warnings;
use pf::constants::exit_code qw($EXIT_SUCCESS);
use pf::services;
use pf::violation_config;
use pf::constants::exit_code qw($EXIT_SUCCESS);
use pf::log;
use base qw(pf::cmd);


sub run {
    pf::violation_config::loadViolationsIntoDb;
    get_logger()->info("Violation classes reloaded");
    print "Violation classes reloaded\n";
    return $EXIT_SUCCESS;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

