package pfappserver::Model::Config::Pfmon;

=head1 NAME

pfappserver::Model::Config::Pfmon add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Pfmon

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::ConfigStore::Pfmon;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::Pfmon->new }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
