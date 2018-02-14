package pf::Sereal;

=head1 NAME

pf::Sereal - Global package for Sereal Encoder/Decoder

=cut

=head1 DESCRIPTION

pf::Sereal

=cut

use strict;
use warnings;
use Sereal::Encoder;
use Sereal::Decoder;
use base qw(Exporter);

our @EXPORT_OK = qw($ENCODER $DECODER);

our $ENCODER = Sereal::Encoder->new;
our $DECODER = Sereal::Decoder->new;

=head2 CLONE

Reinitialize ENCODER/DECODER when a new thread is created

=cut

sub CLONE {
    $ENCODER = Sereal::Encoder->new;
    $DECODER = Sereal::Decoder->new;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
