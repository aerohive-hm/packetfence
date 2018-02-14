use strict;
use warnings;
use Test::More;


unless (eval q{use Test::WWW::Mechanize::Catalyst 'Config::Pf'; 1}) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst required';
    exit 0;
}

ok( my $mech = Test::WWW::Mechanize::Catalyst->new, 'Created mech object' );

$mech->get_ok( 'http://localhost/config/pf' );
done_testing();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

