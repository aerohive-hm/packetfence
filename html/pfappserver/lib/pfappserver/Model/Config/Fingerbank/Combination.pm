package pfappserver::Model::Config::Fingerbank::Combination;

=head1 NAME

pfappserver::Model::Config::Fingerbank::Combination

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Fingerbank::Combination

=cut

use fingerbank::Model::Combination();
use Moose;
use namespace::autoclean;
use HTTP::Status qw(:constants :is);
use Readonly;

Readonly our @EMPTYABLE_ATTRIBUTES => qw(dhcp_fingerprint_id dhcp_vendor_id dhcp6_fingerprint_id dhcp6_enterprise_id mac_vendor_id user_agent_id);

extends 'pfappserver::Base::Model::Fingerbank';

has '+fingerbankModel' => ( default => 'fingerbank::Model::Combination');


sub set_empty_attributes {
    my ($self, $assignments) = @_;
    foreach my $key (@EMPTYABLE_ATTRIBUTES) {
        $assignments->{$key} = $assignments->{$key} // '';
    }
    return $assignments;
}

=head2 create

To create

=cut

sub create {
    my ( $self, $id, $assignments ) = @_;
    $assignments = $self->set_empty_attributes($assignments);
    $self->SUPER::create($id, $assignments);
}

=head2 create

To create

=cut

sub update {
    my ( $self, $id, $assignments ) = @_;
    $assignments = $self->set_empty_attributes($assignments);
    $self->SUPER::update($id, $assignments);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
