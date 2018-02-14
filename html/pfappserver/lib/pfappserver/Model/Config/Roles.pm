package pfappserver::Model::Config::Roles;

=head1 NAME

pfappserver::Model::Config::Roles

=cut

=head1 DESCRIPTION

Model for the roles from roles.conf

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::config;
use pf::ConfigStore::Roles;
use pf::nodecategory;
use pf::log;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::Roles->new }

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

=head2 listFromDB

List the roles from the database

=cut

sub listFromDB {
    my ( $self ) = @_;

    my $logger = get_logger();
    my ($status, $status_msg);

    my @categories;
    eval {
        @categories = nodecategory_view_all();
    };
    if ($@) {
        $status_msg = "Can't fetch node categories from database.";
        $logger->error($status_msg);
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    return ($STATUS::OK, \@categories);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
