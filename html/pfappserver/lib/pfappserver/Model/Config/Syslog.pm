package pfappserver::Model::Config::Syslog;

=head1 NAME

pfappserver::Model::Config::Syslog

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Syslog

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::ConfigStore::Syslog;

extends 'pfappserver::Base::Model::Config';

sub _buildConfigStore { pf::ConfigStore::Syslog->new }

__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
