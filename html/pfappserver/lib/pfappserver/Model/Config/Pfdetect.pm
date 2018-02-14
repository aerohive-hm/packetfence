package pfappserver::Model::Config::Pfdetect;

=head1 NAME

pfappserver::Model::Config::Pfdetect

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Pfdetect

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::config;
use pf::ConfigStore::Pfdetect;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::Pfdetect->new }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
