package pf::cmd::roles::show_parent_help;
=head1 NAME

pf::cmd::roles::show_parent_help add documentation

=cut

=head1 DESCRIPTION

pf::cmd::roles::show_parent_help

=cut

use strict;
use warnings;
use Role::Tiny;

sub showHelp {
    my ($self) = @_;
    $self->{parentCmd}->showHelp();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

