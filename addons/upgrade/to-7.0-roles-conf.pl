#!/usr/bin/perl

=head1 NAME

to-7.0-roles-conf.pl

=cut

=head1 DESCRIPTION

Migrate the roles that are in the database into roles.conf

=cut

use lib '/usr/local/pf/lib';

use pf::nodecategory;
use pf::ConfigStore::Roles;
use pf::util;

run_as_pf();

my @roles = nodecategory_view_all();

my $cs = pf::ConfigStore::Roles->new();

foreach my $role (@roles) {
    delete $role->{category_id};
    my $name = delete $role->{name};
    $cs->update_or_create($name, $role);
}

$cs->commit();

print "All done. The roles that were in the table nodecategory should now appear in /usr/local/pf/conf/roles.conf\n";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

