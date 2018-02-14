package pfconfig::namespaces::config::BillingTiers;

=head1 NAME

pfconfig::namespaces::config::Authentication

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Authentication

This module creates the configuration hash associated to authentication.conf

It also stores the information for @authentication_sources and %authentication_lookup

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($billing_tiers_config_file);
use pf::constants::authentication;
use pf::Authentication::constants;
use pf::Authentication::Action;
use pf::Authentication::Condition;
use pf::Authentication::Rule;
use pf::constants::authentication;

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file}            = $billing_tiers_config_file;
}

sub build_child {
    my ($self) = @_;

    my %cfg = %{ $self->{cfg} };

    foreach my $key (keys %cfg){
        $cfg{$key}{id} = $key;
    }

    return \%cfg;
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

