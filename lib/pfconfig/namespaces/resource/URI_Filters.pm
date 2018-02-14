package pfconfig::namespaces::resource::URI_Filters;

=head1 NAME

pfconfig::namespaces::resource::URI_Filters

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::URI_Filters

=cut

use strict;
use warnings;
use pfconfig::namespaces::config;
use pfconfig::namespaces::config::Profiles;
use pf::factory::condition::profile;

use base 'pfconfig::namespaces::resource';

sub build {
    my ($self) = @_;

    my $config_profiles = pfconfig::namespaces::config::Profiles->new( $self->{cache} );
    my %Profiles_Config = %{ $config_profiles->build };

    return $config_profiles->{uri_filters};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
