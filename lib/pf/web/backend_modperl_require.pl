#!/usr/bin/perl
=head1 NAME

backend_modperl_require.pl

=head1 DESCRIPTION

Pre-loading PacketFence's modules in Apache (mod_perl) for the Web Admin / Web Services Back-End

=cut

use lib "/usr/local/pf/lib";
# dynamicly loaded authentication modules
use lib "/usr/local/pf/conf";

use strict;
use warnings;


use pf::config;
use pf::locationlog;
use pf::node;
use pf::roles::custom;
use pf::Switch;
use pf::SwitchFactory;
use pf::util;

# Forces a pre-load of the singletons to avoid penalty performance on first request
pf::roles::custom->instance();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
