package pfconfig::namespaces::resource::cli_switches;

=head1 NAME

pfconfig::namespaces::resource::cli_switches

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::cli_switches

This module creates the configuration hash of all the switches that have CLI access enabled

=cut

use strict;
use warnings;
use pf::util;

use base 'pfconfig::namespaces::resource';


sub init {
    my ($self) = @_;
    $self->{switches} = $self->{cache}->get_cache('config::Switch');
}

sub build {
    my ($self) = @_;
    my @switches = map { ($_ !~ /^(group |default)/ && exists $self->{switches}->{$_}->{cliAccess} && isenabled($self->{switches}->{$_}->{cliAccess})) ? $_ : () } keys(%{$self->{switches}});
    return \@switches;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# # vim: set expandtab:
# # vim: set backspace=indent,eol,start:

