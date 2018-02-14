package pfconfig::namespaces::FilterEngine::DhcpScopes;

=head1 NAME

pfconfig::namespaces::FilterEngine::DhcpScopes

=cut

=head1 DESCRIPTION

pfconfig::namespaces::FilterEngine::DhcpScopes

=cut

use strict;
use warnings;
use pf::log;
use pfconfig::namespaces::config;
use pfconfig::namespaces::config::DhcpFilters;

use base 'pfconfig::namespaces::FilterEngine::AccessScopes';

sub parentConfig {
    my ($self) = @_;
    return pfconfig::namespaces::config::DhcpFilters->new($self->{cache});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
