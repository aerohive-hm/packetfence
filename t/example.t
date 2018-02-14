=head1 NAME

example pf test

=cut

=head1 DESCRIPTION

example pf test script

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 3;

#This test will running last
use Test::NoWarnings;

#This is the first test
ok (1 == 1,"Yes 1 does equals 1");

#This is the second test
ok (1 != 2,"No 1 does not equals 2");

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


