=head1 NAME

pfconfig::cached_array

=cut

=head1 DESCRIPTION

pfconfig::cached_array

=cut

use strict;
use warnings;
BEGIN {
    use lib qw(/usr/local/pf/t /usr/local/pf/lib);
    use setup_test_config;
}

use Test::More tests => 13;                      # last test to print

use Test::NoWarnings;

##
# Test cached_array
my @array_test;
tie @array_test, 'pfconfig::cached_array', 'resource::array_test';

ok(@array_test eq 3, "test array test is valid");

my @array_test_result = ("first", "second", "third");

ok(@array_test ~~ @array_test_result, "test arrays are the same");

##
# Test FETCH

foreach my $i (0..2){
  is($array_test[$i], $array_test_result[$i],
    "Fetching element $i gives the right result");
}

ok(!defined($array_test[3]),
  "Fetching an inexistant element gives undef");

is(@array_test, 3,
  "Fetching size of array gives the right result");

##
# Test exists in array

ok(exists($array_test[0]), "First element exists");
ok(exists($array_test[1]), "Second element exists");
ok(exists($array_test[2]), "Third element exists");
ok(!exists($array_test[3]), "Fourth element doesn't exists");
ok(exists($array_test[-1]), "-1 element exists");

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


