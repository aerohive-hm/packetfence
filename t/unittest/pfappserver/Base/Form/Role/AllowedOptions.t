#!/usr/bin/perl

=head1 NAME

AllowedOptions

=cut

=head1 DESCRIPTION

unit test for AllowedOptions

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

{

    package test_form;
    use HTML::FormHandler::Moose;
    extends 'pfappserver::Base::Form';
    with qw(pfappserver::Base::Form::Role::AllowedOptions);
}

use Test::More tests => 3;

#This test will running last
use Test::NoWarnings;

my $form = test_form->new( user_roles => ['User Manager'] );

ok( $form, "Form created" );

is_deeply( 
    [ $form->_get_allowed_options('allowed_access_levels') ],
    [ 'User Manager', 'Node Manager', 'NONE' ],
    "Check if _get_allowed_options return expected results"
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

