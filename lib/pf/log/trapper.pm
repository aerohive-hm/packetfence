package pf::log::trapper;

=head1 NAME

pf::log::trapper

=head1 DESCRIPTION

pf::log::trapper traps print to filehandles to a log

=head1 SYNOPSIS

    use pf::log::trapper;
    use Log::Log4perl::Level;
    tie *STDERR,'pf::log::trapper',$ERROR;
    tie *STDOUT,'pf::log::trapper',$DEBUG;

=cut

use strict;
use warnings;
use base qw(Tie::Handle);
use Log::Log4perl;
Log::Log4perl->wrapper_register(__PACKAGE__);

sub TIEHANDLE {
    my $class = shift;
    my $level = shift;
    bless [Log::Log4perl->get_logger(),$level], $class;
}


=head2 PRINT

Print the to logger

=cut

sub PRINT {
    my $self = shift;
    local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
    $self->[0]->log($self->[1],@_);
}

=head2 PRINTF

Implements printf for the TIE::Handle

=cut

sub PRINTF {
    my $self = shift;
    my $buf = sprintf(@_);
    $self->PRINT($buf);
}

=head2 FILENO

Return undef to avoid Cache::BDB from failing sometimes

=cut

sub FILENO { undef }

=head2 CLOSE

CLOSE is a noop just returns 1

=cut

sub CLOSE { 1; }

=head2 OPEN

OPEN is a noop just returns 1

=cut

sub OPEN { 1; }


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

