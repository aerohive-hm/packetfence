package pfappserver::Model::Config::Interface;
=head1 NAME

pfappserver::Model::Config::Profile add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Switch;

=cut

use Moose;
use namespace::autoclean;
use pf::ConfigStore::Interface;

extends 'pfappserver::Base::Model::Config';


=head2 Methods

=over

=item _buildConfigStore

=cut

sub _buildConfigStore { pf::ConfigStore::Interface->new; }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};


=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

