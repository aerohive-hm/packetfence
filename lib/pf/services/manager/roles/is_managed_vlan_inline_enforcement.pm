package pf::services::manager::roles::is_managed_vlan_inline_enforcement;
=head1 NAME

pf::services::manager::roles::is_managed_vlan_inline_enforcement add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::roles::is_managed_vlan_inline_enforcement

=cut

use strict;
use warnings;
use pf::config qw(is_inline_enforcement_enabled is_vlan_enforcement_enabled is_dns_enforcement_enabled);

use Moo::Role;

around isManaged => sub {
    my $orig = shift;
    return (is_inline_enforcement_enabled() || is_vlan_enforcement_enabled() || is_dns_enforcement_enabled()) && $orig->(@_);
};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

