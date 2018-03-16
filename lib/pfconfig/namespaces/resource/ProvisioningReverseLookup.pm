package pfconfig::namespaces::resource::ProvisioningReverseLookup;

=head1 NAME

pfconfig::namespaces::resource::ProvisioningReverseLookup -

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::ProvisioningReverseLookup

=cut

use strict;
use warnings;
use pfconfig::namespaces::config;
use pfconfig::namespaces::config::Provisioning;;
use base 'pfconfig::namespaces::resource';

sub build {
    my ($self) = @_;

    my $config = pfconfig::namespaces::config::Provisioning->new( $self->{cache} );
    $config->build;

    return $config->{reverseLookup};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

