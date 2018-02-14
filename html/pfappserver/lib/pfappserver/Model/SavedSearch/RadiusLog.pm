package pfappserver::Model::SavedSearch::RadiusLog;

=head1 NAME

package pfappserver::Model::SavedSearch::RadiusLog

=cut

=head1 DESCRIPTION

SavedSearch for Nodes

=over

=cut

use strict;
use warnings;
use Moose;

extends 'pfappserver::Base::Model::SavedSearch';


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

