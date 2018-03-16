package pfappserver::Model::Config::TrafficShaping;

=head1 NAME

pfappserver::Model::Config::TrafficShaping add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::TrafficShaping

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::ConfigStore::TrafficShaping;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::TrafficShaping->new }

__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=cut

1;
