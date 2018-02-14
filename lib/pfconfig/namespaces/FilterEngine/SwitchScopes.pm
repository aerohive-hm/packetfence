package pfconfig::namespaces::FilterEngine::SwitchScopes;

=head1 NAME

pfconfig::namespaces::FilterEngine::SwitchScopes

=cut

=head1 DESCRIPTION

pfconfig::namespaces::FilterEngine::SwitchScopes

=cut

use strict;
use warnings;
use pf::log;
use pfconfig::namespaces::config;
use pfconfig::namespaces::config::SwitchFilters;

use base 'pfconfig::namespaces::FilterEngine::AccessScopes';

sub parentConfig {
    my ($self) = @_;
    return pfconfig::namespaces::config::SwitchFilters->new($self->{cache});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
