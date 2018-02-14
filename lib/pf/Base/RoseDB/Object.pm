package pf::Base::RoseDB::Object;
=head1 NAME

pf::Base::RoseDB::Object add documentation

=cut

=head1 DESCRIPTION

pf::Base::RoseDB::Object

=cut

use strict;
use warnings;
use base 'Rose::DB::Object';

use pf::RoseDB;

sub init_db { pf::RoseDB->new() }

1;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

