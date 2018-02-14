package pf::pftest::locationlog;
=head1 NAME

pf::pftest::locationlog

=head1 SYNOPSIS

pftest locationlog

=head1 DESCRIPTION

pf::pftest::locationlog

=cut

use strict;

use warnings;
use base qw(pf::cmd);
use pf::constants::exit_code qw($EXIT_SUCCESS $EXIT_FAILURE);
use pf::constants qw($ZERO_DATE);
sub parseArgs { $_[0]->args == 0 }

sub _run {
    my ($self) = @_;
    require pf::db;
    my $dbh = pf::db::db_connect();
    my $sth = $dbh->prepare(qq[ select mac,count(mac) as entries from locationlog where end_time = '$ZERO_DATE' group by mac having count(mac) > 1; ]);
    die unless $sth;
    $sth->execute();
    my $rv  = $sth->rows;
    my $format_header = "%-17s %10s\n";
    print "Found $rv nodes with multiple opened locationlog entries\n";
    return $EXIT_SUCCESS unless $rv > 0;
    print sprintf($format_header,"mac", "count");
    while(my $row = $sth->fetchrow_hashref) {
        print sprintf( "%-17s %10d\n",$row->{mac}, $row->{entries});
    }
    return 0;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

