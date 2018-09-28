package pfappserver::Model::Update;

=head1 NAME

pfappserver::Model::Update - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;
use Readonly;

Readonly::Scalar our $UPDATE_CMD   => '/usr/bin/systemctl start a3-update';
Readonly::Scalar our $PROGRESS_LOG => '/usr/local/pf/html/update/a3_update.progress';
Readonly::Scalar our $UPDATE_LOCK  => '/usr/local/pf/var/run/update.lock';

use Moose;

use pf::log;
use pf::error qw(is_success is_error);
use pf::constants qw($TRUE $FALSE);
use pf::a3_update;
use pf::version;

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
    if ( ! lock_for_update() ) {
        return $STATUS::CONFLICT;
    }

    my ($status) = fetch_latest_release();

    if ($status == $STATUS::OK) {
        system("/usr/bin/sudo $UPDATE_CMD &");
        return $STATUS::ACCEPTED;
    }
    else {
        return $STATUS::INTERNAL_SERVER_ERROR;
    }
}

=head2 get_update_status

Get the current status of the update process

=cut

sub get_update_status {
    my @text = read_file($PROGRESS_LOG);

    return \@text;
}

sub lock_for_update {
    my $logger = get_logger();

    if (sysopen LOCKFILE, $UPDATE_LOCK, O_WRONLY | O_CREAT | O_EXCL, 0600) {
        $logger->info("Locking for update");
        close LOCKFILE;
        return $TRUE;
    }
    else {
        $logger->info("Update already in progress");
        return $FALSE;
    }
}

sub is_update_in_progress {
    return -e $UPDATE_LOCK;
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
