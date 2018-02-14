use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'pfappserver' }
BEGIN { use_ok 'pfappserver::Controller::Config' }

ok( request('/config')->is_success, 'Request should succeed' );
done_testing();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

