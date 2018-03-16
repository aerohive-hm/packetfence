#!/usr/bin/perl

=head1 NAME

AdminRoles

=cut

=head1 DESCRIPTION

unit test for AdminRoles

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
our @INVALID_INPUT;

BEGIN {
    @INVALID_INPUT = (
        {
            in  => {},
            msg => "Empty input",
        },
        {
            in  => { id => 'bob' },
            msg => "Only ID",
        },
        {
            in  => { description => 'bob' },
            msg => "Only description",
        },
        {
            in  => { garbage => 'bob' },
            msg => "Garbage input",
        },
    );
}

use pfappserver::Form::Config::AdminRoles;

use Test::More tests => 3 + scalar @INVALID_INPUT;

#This test will running last
use Test::NoWarnings;

my $form  = pfappserver::Form::Config::AdminRoles->new();
#This is the first test
ok ($form, "Create a new form");

ok (ref $form->roles eq 'ARRAY', "Roles attribute is set");


{

    for my $test (@INVALID_INPUT) {
        $form = pfappserver::Form::Config::AdminRoles->new();
        $form->process(params => $test->{in}, posted => 1);
        ok($form->has_errors(), $test->{msg});
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

