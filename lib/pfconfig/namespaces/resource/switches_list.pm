package pfconfig::namespaces::resource::switches_list;

=head1 NAME

pfconfig::namespaces::resource::switches_group

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::switches_group

This module creates the configuration hash of all the switches group

=cut

use strict;
use warnings;
use pf::ConfigStore::Switch;

use base 'pfconfig::namespaces::resource';


sub init {
    my ($self) = @_;
    $self->{switches} = \%pf::SwitchFactory::SwitchConfig;
}



sub build {
    my ($self) = @_;
    my $switches = {};
    foreach my $switch_id (keys %{$self->{switches}}) {
        $switches->{$switch_id} = $switch_id if ($switch_id ne 'default' && $switch_id ne '127.0.0.1' && $switch_id !~ /^group/);
    }
    return $switches;
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
