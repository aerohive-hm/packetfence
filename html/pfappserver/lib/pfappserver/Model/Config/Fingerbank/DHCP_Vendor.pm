package pfappserver::Model::Config::Fingerbank::DHCP_Vendor;

=head1 NAME

pfappserver::Model::Config::Fingerbank::DHCP_Vendor

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Fingerbank::DHCP_Vendor

=cut

use fingerbank::Model::DHCP_Vendor();
use Moose;
use namespace::autoclean;
use HTTP::Status qw(:constants :is);

extends 'pfappserver::Base::Model::Fingerbank';

has '+fingerbankModel' => ( default => 'fingerbank::Model::DHCP_Vendor');


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
