package pfappserver::Model::Config::BillingTiers;

=head1 NAME

pfappserver::Model::Config::BillingTiers

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::BillingTiers

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::config;
use pf::ConfigStore::BillingTiers;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::BillingTiers->new }

=head2 Methods

=over

=item search

=cut

sub search {
    my ($self, $field, $value) = @_;
    my @results = $self->configStore->search($field, $value);
    if (@results) {
        return ($STATUS::OK, \@results);
    } else {
        return ($STATUS::NOT_FOUND,["[_1] matching [_2] not found"],$field,$value);
    }
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

