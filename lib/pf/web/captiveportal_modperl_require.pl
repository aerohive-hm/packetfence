#!/usr/bin/perl

=head1 NAME

captiveportal_modperl_require.pl - Pre-loading PacketFence's modules in Apache (mod_perl) for the Captive Portal

=cut

use strict;
use warnings;

BEGIN {
    use lib "/usr/local/pf/lib";
    use pf::log 'service' => 'httpd.portal', reinit => 1;
}

use Cache::FileCache();
use pf::config();
use pf::util();
use pf::web();
use pf::web::guest();
# needs to be called last of the pf::web's to allow dark magic redefinitions
use pf::web::custom();
use pf::node();
use pf::locationlog();

# Log4perl initialization
# Testing it out but we might need to reconsider if we get adversely affected
# by problem described here:
# http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl/FAQ.html#792b4

our $lost_devices_cache = new Cache::FileCache( { 'namespace' => 'CaptivePortal_LostDevices' } );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
