#!/usr/bin/perl
=head1 NAME

locationlog-cleanup.pl - runs the locationlog clean task

=head1 SYNOPSIS

locationlog-cleanup.pl [--expire SECONDS] [--batch BATCH] [--timeout SECONDS]

 Options:
  --expire   The expire time of the locationlog in seconds     - default expire.locationlog
  --batch    The number of locationlog entries to batch delete - default maintenance.locationlog_cleanup_batch
  --timeout  How long this job is allowed to run               - default maintenance.locationlog_cleanup_timeout
  --help     Shows this help

=head1 DESCRIPTION

locationlog-cleanup

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::config qw(%Config);
use pf::locationlog;

use Getopt::Long;
use Pod::Usage;

my %options = (
    expire   => $Config{'maintenance'}{'locationlog_cleanup_window'},
    batch    => $Config{maintenance}{locationlog_cleanup_batch},
    timeout  => $Config{maintenance}{locationlog_cleanup_timeout},
    help     => undef,
);

GetOptions(\%options,"expire=s","batch=s","timeout=s","help|h") || pod2usage(2);

pod2usage(1) if $options{help};

pod2usage(-msg  => "Expire must be greater than 0", -exitval => 2, -verbose => 0) unless $options{expire};

locationlog_cleanup(@options{qw(expire batch timeout)});

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

