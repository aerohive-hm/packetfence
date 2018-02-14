package pf::lookup::person;

=head1 NAME

pf::lookup::person - lookup person information

=head1 SYNOPSYS

The lookup_person function is called via
"pfcmd lookup person E<lt>pidE<gt>"
through the administrative GUI,
or as the content of a violation action

Define this function to return whatever data you'd like.

=cut

use strict;
use warnings;
use Net::LDAP;

use pf::log;
use pf::person;
use pf::util;
use pf::authentication;
use pf::pfqueue::producer::redis;
use pf::CHI;

my $CHI_CACHE = pf::CHI->new( namespace => 'person_lookup' );

=head2 lookup_person

Lookup informations on a person

=cut

sub lookup_person {
    my ($pid, $source_id) = @_;
    my $logger = get_logger();
    unless (defined $source_id) {
        $logger->info("undefined source id provided");
        return;
    }
    my $source = pf::authentication::getAuthenticationSource($source_id);
    if (!$source) {
       $logger->info("Unable to locate the source $source_id");
       return;
    }

    unless (person_exist($pid)) {
        $logger->info("Person $pid is not a registered user!");
        return;
    }
    my $person = $CHI_CACHE->get("$source_id.$pid");
    unless($person){
        $person = $source->search_attributes($pid);
        if (!$person) {
           $logger->debug("Cannot search attributes for user '$pid'");
           return;
        } else {
            $CHI_CACHE->set("$source_id.$pid", $person);
            $logger->info("Successfully did a person lookup for $pid");
            person_modify($pid, %$person);
            return;
        }
    }
    $logger->info("Already did a person lookup for $pid");
    return;
}

=head2 async_lookup_person

Lookup a person asynchronously using the queue

=cut

sub async_lookup_person {
    my ($pid, $source_id) = @_;
    my $client = pf::pfqueue::producer::redis->new();
    $client->submit("general", person_lookup => {pid => $pid, source_id => $source_id});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
