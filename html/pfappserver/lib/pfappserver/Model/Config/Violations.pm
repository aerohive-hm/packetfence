package pfappserver::Model::Config::Violations;

=head1 NAME

pfappserver::Model::Config::Violations

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Violations

=cut

use Moose;
use namespace::autoclean;

use pf::config qw(%CAPTIVE_PORTAL %Profiles_Config);
use pf::violation_config;
use HTTP::Status qw(:constants is_error is_success);
use pf::ConfigStore::Violations;
use List::MoreUtils qw(uniq);

extends 'pfappserver::Base::Model::Config';

sub _buildConfigStore { pf::ConfigStore::Violations->new }

=head1 Methods

=head2 availableTemplates

Return the list of available remediation templates

=cut

sub availableTemplates {
    my @dirs = map { uniq(@{pf::Connection::ProfileFactory->_from_profile($_)->{_template_paths}}) } keys(%Profiles_Config);
    my @templates;
    foreach my $dir (@dirs) {
        next unless opendir(my $dh, $dir . '/violations');
        push @templates, grep { /^[^\.]+\.html$/ } readdir($dh);
        s/\.html// for @templates;
        closedir($dh);
    }
    @templates = sort(uniq(@templates));
    return \@templates;
}

=head2 listTriggers

=cut

sub listTriggers {
    my ($self) = @_;
    return $self->configStore->listTriggers;
}


=head2 addTrigger

=cut

sub addTrigger {
    my ( $self,$id,$trigger ) = @_;
    my ($status,$status_msg) = $self->hasId($id);
    if(is_success($status)) {
        my $result = $self->configStore->addTrigger($id,$trigger);
        $status_msg = $result == 1  ? "Successfully added trigger to violation" : 'Trigger already included.';
    }
    return ($status,$status_msg);
}

=head2 deleteTrigger

=cut

sub deleteTrigger {
    my ( $self,$id,$trigger ) = @_;
    my ($status,$status_msg) = $self->hasId($id);
    if(is_success($status)) {
        my $result = $self->configStore->deleteTrigger($id,$trigger);
        $status_msg = $result == 1  ? "Successfully deleted trigger from violation" : 'Trigger already excluded.';
    }
    return ($status,$status_msg);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

