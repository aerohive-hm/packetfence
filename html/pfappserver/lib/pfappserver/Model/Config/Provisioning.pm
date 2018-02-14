
package pfappserver::Model::Config::Provisioning;

=head1 NAME

pfappserver::Model::Config::Provisioning add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Provisioning

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::ConfigStore::Provisioning;

extends 'pfappserver::Base::Model::Config';

=head2 Methods

=over

=item _buildConfigStore

buld the config store

=cut

sub _buildConfigStore { pf::ConfigStore::Provisioning->new }


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


