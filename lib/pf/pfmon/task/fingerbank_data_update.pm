package pf::pfmon::task::fingerbank_data_update;

=head1 NAME

pf::pfmon::task::fingerbank_data_update - class for pfmon task fingerbank data update

=cut

=head1 DESCRIPTION

pf::pfmon::task::fingerbank_data_update

=cut

use strict;
use warnings;
use fingerbank::Config;
use fingerbank::Redis;
use fingerbank::DB;
use pf::fingerbank;
use pf::constants qw($TRUE $FALSE);
use pf::cluster;
use pf::log;
use Moose;
extends qw(pf::pfmon::task);

our $MYSQL_ACTION = 'update-mysql-db';

=head2 run

Update all the Fingerbank data from the API

=cut

sub run {

    if(fingerbank::Config::is_api_key_configured){
        foreach my $action (keys(%pf::fingerbank::ACTION_MAP)){
            next if $action eq $MYSQL_ACTION;
            if(defined($pf::fingerbank::ACTION_MAP_CONDITION{$action})){
                unless($pf::fingerbank::ACTION_MAP_CONDITION{$action}->()){
                    get_logger->debug("Not executing $action because its condition returned false");
                    next;
                }
            }
            get_logger->debug("Calling Fingerbank action $action");
            my ($status, $status_msg) = pf::cluster::notify_each_server('fingerbank_update_component', action => $action, email_admin => $FALSE, fork_to_queue => $TRUE);
            if(fingerbank::Util::is_success($status)){
                get_logger->info("Successfully executed action $action");
            }
            else {
                get_logger->error("Couldn't execute action $action : ". ($status_msg // "Unknown Error"));
            }
        }
        my $apiclient = pf::client::getClient();
        $apiclient->notify('fingerbank_update_component', action => $MYSQL_ACTION, email_admin => $FALSE, fork_to_queue => $TRUE);
    }
    else {
        get_logger->debug("Can't update fingerbank data since there is no API key configured");
    }

}


=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
