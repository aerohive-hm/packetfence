package pf::cmd::roles::show_help;
=head1 NAME

pf::cmd::roles::show_help add documentation

=cut

=head1 DESCRIPTION

pf::cmd::roles::show_help

=cut

use strict;
use warnings;
use Pod::Usage qw(pod2usage);
use IO::Interactive qw(is_interactive);
use Pod::Text::Termcap;
if(is_interactive) {
@Pod::Usage::ISA = ('Pod::Text::Termcap');
}
use Pod::Find qw(pod_where);
use Role::Tiny;

sub showHelp {
    my ($self,$package) = @_;
    $package ||= ref($self) || $self;
    my $location = pod_where({-inc => 1}, $package);
    pod2usage({
        -message => $self->{help_msg} ,
        -input => $location,
        -exitval => 0,
    });
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

