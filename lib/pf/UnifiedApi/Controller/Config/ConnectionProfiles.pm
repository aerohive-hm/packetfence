package pf::UnifiedApi::Controller::Config::ConnectionProfiles;

=head1 NAME

pf::UnifiedApi::Controller::Config::ConnectionProfiles -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::ConnectionProfiles

=cut

use strict;
use warnings;
use Mojo::Base qw(pf::UnifiedApi::Controller::Config);
use pf::ConfigStore::Profile;
use pfappserver::Form::Config::Profile;
use pfappserver::Form::Config::Profile::Default;

has 'config_store_class' => 'pf::ConfigStore::Profile';
has 'form_class' => 'pfappserver::Form::Config::Profile';
has 'primary_key' => 'connection_profile_id';

sub form {
    my ($self, $item) = @_;
    if ( ($item->{id} // '') eq 'default') {
        return pfappserver::Form::Config::Profile::Default->new;
    }
    return $self->SUPER::form($item);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
