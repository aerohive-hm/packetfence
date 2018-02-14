package pfconfig::namespaces::resource::SwitchTypesConfigured;

=head1 NAME

pfconfig::namespaces::resource::SwitchTypesConfigured

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::SwitchTypesConfigured

This module creates a hash of all the configured switches

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

use NetAddr::IP;

=head2 init

Initialize the pfconfig::namespaces::resource::SwitchTypesConfigured object

=cut

sub init {
    my ($self) = @_;
    # we depend on the switch configuration object (russian doll style)
    $self->{switches} = $self->{cache}->get_cache('config::Switch');
}

=head2 build

Builds a hash of all the configured switches

=cut

sub build {
    my ($self) = @_;
    my %types;
    my @ranges;
    foreach my $data ( values %{$self->{switches}} ) {
        my $type = $data->{type};
        next if !defined $type;
        $types{"pf::Switch::$type"} = 1;
    }
    return \%types;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

