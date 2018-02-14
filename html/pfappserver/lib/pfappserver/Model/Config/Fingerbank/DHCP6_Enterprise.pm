package pfappserver::Model::Config::Fingerbank::DHCP6_Enterprise;

=head1 NAME

pfappserver::Model::Config::Fingerbank::DHCP6_Enterprise

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Fingerbank::DHCP6_Enterprise

=cut

use fingerbank::Model::DHCP6_Enterprise();
use Moose;
use namespace::autoclean;
use HTTP::Status qw(:constants :is);

extends 'pfappserver::Base::Model::Fingerbank';

has '+fingerbankModel' => ( default => 'fingerbank::Model::DHCP6_Enterprise');


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
