#!/usr/bin/perl

=head1 NAME

to-3.5-pf.conf.pl - 3.5 upgrade script for conf/pf.conf

=head1 USAGE

Basically: 

  addons/upgrade/to-3.5-pf.conf.pl < conf/pf.conf > pf.conf.new

Then look at pf.conf.new and if it's ok, replace your conf/pf.conf with it.

=head1 DESCRIPTION

Here's what this script fixes:

=over

=item per-interface gateway

No longer required. We just drop it.

=back

=cut

use strict;
use warnings;

while (<>) {

    # a special case of gateway which we won't change
    print if (/^\s*gateway\s*=\s*authorize_net\s*$/i);

    # removing gateway parameter
    next if (/^\s*gateway\s*=.*$/i);

    # removing the caching parameter
    next if (/^\s*caching\s*=.*$/i);

    # removing nessus_clientfile parameter
    next if (/^\s*nessus_clientfile\s*=.*$/i);

    # if we didn't skip, we keep
    print;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

