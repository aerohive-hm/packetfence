#!/usr/bin/perl

=head1 NAME

captiveportal_modperl_require.pl - Pre-loading PacketFence's modules in Apache (mod_perl) for the Captive Portal

=cut

use strict;
use warnings;

BEGIN {
    use lib "/usr/local/pf/lib";
    use pf::log 'service' => 'httpd.proxy', reinit => 1;
}

use pf::web::interceptproxy;


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
