package pfappserver::Model::Config::SwitchGroup;
=head1 NAME

pfappserver::Model::Config::SwitchGroup

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::SwitchGroup;

=cut

use Moose;
use namespace::autoclean;
use pf::ConfigStore::SwitchGroup;
use HTTP::Status qw(:constants :is);

extends 'pfappserver::Base::Model::Config';


=head1 Methods

=head2 _buildConfigStore

=cut

sub _buildConfigStore { pf::ConfigStore::SwitchGroup->new; }

=head2 remove

Override the parent method to validate we don't remove a group that has childs

=cut

sub remove {
    my ($self, $id) = @_;
    pf::log::get_logger->info("Deleting $id");
    my @childs = $self->configStore->members($id, $self->idKey);
    if(@childs){
        my @switch_ids = map { $_->{id} } @childs;
        my $switch_csv = join(', ', @switch_ids);
        my $status_msg = ["Cannot remove group [_1] because it is still used by the following switches : [_2]",$id, $switch_csv];
        my $status =  HTTP_PRECONDITION_FAILED;
        return ($status, $status_msg);
    }
    else {
        return $self->SUPER::remove($id);
    }
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


