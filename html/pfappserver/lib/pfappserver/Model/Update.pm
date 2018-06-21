package pfappserver::Model::Update;

=head1 NAME

pfappserver::Model::Update - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;
use Readonly;

Readonly::Scalar our $UPDATE_SCRIPT => '/usr/local/pf/sbin/a3_update';

use Moose;

use pf::log;
use pf::error qw(is_success is_error);
use pf::constants qw($TRUE $FALSE);
use pf::a3_update;
use pf::version;

use WWW::Curl::Easy;

use Data::Dumper;

extends 'Catalyst::Model';

=head1 METHODS

=head2 fetch_latest_release

Retrieve information about the current released version of A3 from ACS.

=cut

sub fetch_latest_release {
    my $logger = get_logger();

    # Call into ACS to fetch information
    my ($is_success, $result) = pf::a3_update::get_latest_release_from_acs();

    $logger->info("get_latest_release_from_acs() returned $is_success");

    if ($is_success) {
        $logger->debug("Response from ACS: " . Dumper($result));

        # Check whether release is newer
        if (pf::a3_update::compare_versions(pf::version::version_get_current(), $result->{version}) < 0) {
            return $STATUS::OK, $result;
        }
        else {
            return $STATUS::NO_CONTENT;
        }
    }

    $logger->error("Unable to retrieve information about the latest release");

    return $STATUS::INTERNAL_SERVER_ERROR;
}

=head2 start_update

Start the update process

=cut

sub start_update {
    my $logger = get_logger();

    # TODO: Check for update in progress

    my ($status) = fetch_latest_release();

    if ($status == $STATUS::OK) {
        # fork/exec the update script
        my $pid = fork();

        if ($pid) {
            return $STATUS::ACCEPTED;
        }
        elsif (defined $pid) {
            $logger->info("Executing update script at $UPDATE_SCRIPT");

            exec $UPDATE_SCRIPT;
        }
        else {
            $logger->error("Failed to fork child process to run update script: $!");
            return $STATUS::INTERNAL_SERVER_ERROR;
        }
    }
    elsif ($status == $STATUS::NO_CONTENT) {
        $logger->info("Current version is already the latest available");
        return $STATUS::NOT_FOUND;
    }
    else {
        return $STATUS::INTERNAL_SERVER_ERROR;
    }
}

=head2 get_update_status

Get the current status of the update process

=cut

sub get_update_status {
    # TODO - finalize how this information will be communicated to front end
}


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
