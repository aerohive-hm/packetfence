#!/usr/bin/perl

=head1 NAME

pflogger - 

=cut

=head1 DESCRIPTION

pflogger

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use POSIX;

my @args;

my $name = $0;

if ($name =~ m#/usr/local/pf/bin/pflogger-(.*)#) {
    push @args, '-t', $1;
}

close_inherited_file_descriptors();
exec('/usr/bin/systemd-cat', @args);

sub close_inherited_file_descriptors {
    my $max = POSIX::sysconf( &POSIX::_POSIX_OPEN_MAX );
    # Close all open file descriptors other than STDIN, STDOUT, and STDERR
    # To avoid resource leaking
    POSIX::close( $_ ) for 3 .. ($max - 1);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

