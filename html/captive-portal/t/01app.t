#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'captiveportal';

ok( request('/')->is_success, 'Request should succeed' );

done_testing();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

