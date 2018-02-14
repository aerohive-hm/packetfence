package pfconfig::namespaces::resource::switches_group;

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
    $self->{switches_group} = pf::ConfigStore::Switch->new()->readAllIds();
}



sub build {
    my ($self) = @_;
    my @switches_group = map { my $a = $_; $a =~ s/group //;$a} grep { $_ =~ /group/} @{$self->{switches_group}};
    my $switches_group = {};
    foreach my $group (@switches_group) {
        $switches_group->{$group} = $group;
    }
    return $switches_group;
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
