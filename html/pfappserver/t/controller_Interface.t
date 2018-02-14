use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'pfappserver' }
BEGIN { use_ok 'pfappserver::Controller::Interface' }

ok( request('/interface')->is_success, 'Request should succeed' );
done_testing();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

