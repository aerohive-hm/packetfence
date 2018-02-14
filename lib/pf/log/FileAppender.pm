package pf::log::FileAppender;

=head1 NAME

pf::log::FileAppender

=cut

=head1 DESCRIPTION

Used to extend the Log4perl file appender so it doesn't die on failure.

=cut

use base qw( Log::Log4perl::Appender::File );
use strict;
use warnings;

sub log {
     my($self, @args) = @_;

     local $Log::Log4perl::caller_depth =
           $Log::Log4perl::caller_depth + 1;

     eval { $self->SUPER::log(@args) };
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

