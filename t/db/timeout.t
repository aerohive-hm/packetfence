=head1 NAME

schema

=cut

=head1 DESCRIPTION

test the latest schema of PacketFence
Requires the root db password to be set in the environmentally variable PF_TEST_DB_PASS

Example:

  PF_TEST_DB_PASS=passwd perl t/db/schema.t

=cut

use strict;
use warnings;
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use pf::db;
use Test::More tests => 5;                      # last test to print

use Test::NoWarnings;

my $dbh  = eval {
    db_connect();
};


my $sql = "SELECT SLEEP(2) as sleep;";

BAIL_OUT("Cannot connect to dbh") unless $dbh;

my $sth = $dbh->prepare($sql);

$sth->execute();

my $row = $sth->fetchrow_hashref;

is($row->{sleep}, 0, "Sleep did not timeout");

$sth->finish;

db_set_max_statement_timeout(1);

$dbh = db_connect();

$sth = $dbh->prepare($sql);

$sth->execute();

$row = $sth->fetchrow_hashref;

is($row->{sleep}, 1, "Sleep did timeout");

$sth->finish;

is(pf::db::convert_timeout("0.0", 1.0), 1.0, "Return float");

is(pf::db::convert_timeout("0", 1.0), 1000, "Return integer");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
