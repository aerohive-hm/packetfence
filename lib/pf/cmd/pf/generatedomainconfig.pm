package pf::cmd::pf::generatedomainconfig;
=head1 NAME

pf::cmd::pf::generatedomainconfig

=head1 SYNOPSIS

 pfcmd generatedomainconfig

generates the OS configuration for the domain binding

=head1 DESCRIPTION

pf::cmd::pf::generatedomainconfig

=cut

use strict;
use warnings;

use base qw(pf::cmd);

use pf::domain;
use pf::util;
use pf::constants::exit_code qw($EXIT_SUCCESS);

sub _run {
    my ($self) = @_;
    pf::domain::generate_krb5_conf();
    pf::domain::generate_smb_conf();
    pf::domain::generate_resolv_conf();
    pf_run("sudo /usr/local/pf/bin/pfcmd service iptables restart");
    pf::domain::restart_winbinds();
    return $EXIT_SUCCESS; 
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

