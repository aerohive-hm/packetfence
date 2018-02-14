package pf::cmd::pf::class::view;
=head1 NAME

pf::cmd::pf::class::view add documentation

=cut

=head1 DESCRIPTION

pf::cmd::pf::class::view

=cut

use strict;
use warnings;
use base qw(pf::cmd);
use pf::class;

sub run {
    my ($self) = @_;
    my ($id) = $self->args;
    my $function;
    if ( $id && $id !~ /all/ ) {
        $function = \&class_view;
    } else {
        $function = \&class_view_all;
    }
    return $self->print_results( $function, $id ) ;
}

sub field_order_ui { "class view" }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

