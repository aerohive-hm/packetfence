package pf::UnifiedApi::Controller::Config::Bases;

=head1 NAME

pf::UnifiedApi::Controller::Config::Bases - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Bases



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::Pf';
has 'form_class' => 'pfappserver::Form::Config::Pf';
has 'primary_key' => 'base_id';

use pf::ConfigStore::Pf;
use pfappserver::Form::Config::Pf;

sub form_parameters {
    my ($self, $item) = @_;
    my $name = $self->id // $item->{id};
    if (!defined $name) {
        return undef;
    }
    return [name => $name];
}

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

