#!/usr/bin/perl

=head1 NAME

to-3.0-violations.conf.pl - 3.0 upgrade script for conf/violations.conf

=head1 USAGE

Basically: 

  addons/upgrade/to-3.0-violations.conf.pl < conf/violations.conf > violations.conf.new

Then look at violations.conf.new and if it's ok, replace your conf/violations.conf with it.

=head1 DESCRIPTION

Replaces disable=value into enabled=!value.

=cut

use strict;
use warnings;

while (<>) {
    if (/^disable=(.*)$/i) {
        print "enabled=", ( $1 =~ /[yY]/ ? 'N' : 'Y' ), "\n";
    } else {
        print;
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

