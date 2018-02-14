package pf::RoseDB;

=head1 NAME

pf::RoseDB add documentation

=cut

=head1 DESCRIPTION

pf::RoseDB

=cut

use strict;
use warnings;

use Rose::DB;
use pf::db;
use List::MoreUtils qw(any);
our @ISA = qw(Rose::DB);

__PACKAGE__->use_private_registry;

# Register your lone data source using the default type and domain
our $DB_Config = $pf::Config{'database'};

__PACKAGE__->register_db(
    domain   => pf::RoseDB->default_domain,
    type     => pf::RoseDB->default_type,
    driver   => 'mysql',
    connect_options => {
        RaiseError => 0,
        PrintError => 0,
        mysql_auto_reconnect => 0,
    },
);

sub dbh {
    my $dbh;
    eval {
        $dbh = db_connect(); 
    };
    return $dbh;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

