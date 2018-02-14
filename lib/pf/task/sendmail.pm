package pf::task::sendmail;

=head1 NAME

pf::task::sendmail - Task for sending mail

=cut

=head1 DESCRIPTION

pf::task::sendmail

=cut

use strict;
use warnings;
use base 'pf::task';
use POSIX;
use pf::util qw(untaint_chain);
use pf::log;
use pf::config;
use pf::config::util;
my $logger = get_logger();

=head2 doTask

Sendmail

=cut

sub doTask {
    my ($self, $args) = @_;
    return pf::config::util::send_email(@$args);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
