package pfappserver::Model::EulaAcceptance;

=head1 NAME

pfappserver::Model::EulaAcceptance - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;

use pf::log;
use pf::constants qw($TRUE $FALSE);
use pf::a3_eula_acceptance;

extends 'Catalyst::Model';

=head1 METHODS

=head2 record_eula_acceptance

Save a local record that the user has accepted the Aerohive End User License Agreement

=cut

sub record_eula_acceptance {
    my $logger = get_logger();

    my $now = DateTime->now;

    if (pf::a3_eula_acceptance::record_local($now)) {
        $logger->info("recorded EULA acceptance, notifying ACS");

        if (pf::a3_eula_acceptance::record_acs($now)) {
            $logger->info("ACS acknowledged EULA acceptance, updating sync flag");
            pf::a3_eula_acceptance::record_sync($now);
            return $TRUE;
        }
        else {
            $logger->error("Failed to notify ACS of EULA acceptance");
        }
    }

    return $FALSE;
}

=head2 is_eula_accepted

Check whether the Aerohive End User License Agreement has been accepted

=cut

sub is_eula_accepted {
    return pf::a3_eula_acceptance::is_eula_accepted();
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
