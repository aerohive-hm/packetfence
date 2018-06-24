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
Readonly::Scalar our $PROGRESS_LOG  => '/usr/local/pf/logs/a3_update_progress.log';
Readonly::Scalar our $UPDATE_LOCK   => '/usr/local/pf/var/run/update.lock';

use Moose;

use pf::log;
use pf::error qw(is_success is_error);
use pf::constants qw($TRUE $FALSE);
use pf::a3_update;
use pf::version;

use WWW::Curl::Easy;

use Data::Dumper;
use File::Slurp;
use Fcntl;

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
    if ( ! lock_for_update() ) {
        return $STATUS::CONFLICT;
    }

    my ($status) = fetch_latest_release();

    if ($status == $STATUS::OK) {
        # fork/exec the update script
        my $pid = fork();

        if ($pid) {
            return $STATUS::ACCEPTED;
        }
        elsif (defined $pid) {
            $logger->info("Executing update script at $UPDATE_SCRIPT");

            exec "/usr/bin/sudo $UPDATE_SCRIPT";
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
    return read_file($PROGRESS_LOG);
}

sub lock_for_update {
    my $logger = get_logger();

    if (sysopen LOCKFILE, $UPDATE_LOCK, O_WRONLY | O_CREAT | O_EXCL, 0600) {
        $logger->info("Locking for update");
        close LOCKFILE;
    }
    else {
        $logger->info("Update already in progress");
    }
}


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
