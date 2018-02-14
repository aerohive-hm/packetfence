#!/usr/bin/perl
=head1 NAME

pfconfig::memory_cached

=cut

=head1 DESCRIPTION

pfconfig::memory_cached

=cut

use strict;
use warnings;
BEGIN {
    use lib qw(/usr/local/pf/t /usr/local/pf/lib);
    use test_paths;
    use setup_test_config;
}

use Test::More tests => 10;                      # last test to print

use Test::NoWarnings;

use_ok("pfconfig::memory_cached");
use_ok("pfconfig::manager");

my $testkey = "testkey";
my $testns = "testns";
my $testns2 = "testns2";

my $mem = pfconfig::memory_cached->new($testns);

my $manager = pfconfig::manager->new();
$manager->touch_cache($testns);
$manager->touch_cache($testns2);

my $result;

$result = $mem->compute_from_subcache($testkey, sub {"dinde"});
is($result, "dinde", 
    "Computing should return proper value");

$result = $mem->compute_from_subcache($testkey, sub {"that-would-be-bad"});
is($result, "dinde", 
    "Computing should return cached value if namespace hasn't expired");

$manager->touch_cache($testns);

$result = $mem->compute_from_subcache($testkey, sub {"value changed !"});
is($result, "value changed !", 
    "Value is properly recompute_from_subcached when namespace expired.");

$mem = pfconfig::memory_cached->new($testns, $testns2);

$result = $mem->compute_from_subcache($testkey, sub {"dinde"});
is($result, "dinde", 
    "Computing should return proper value");

$result = $mem->compute_from_subcache($testkey, sub {"that-would-be-bad"});
is($result, "dinde", 
    "Computing should return cached value if no namespace has expired in the namespace list");

$manager->touch_cache($testns);

$result = $mem->compute_from_subcache($testkey, sub {"value changed !"});
is($result, "value changed !", 
    "Value is properly recompute_from_subcached when one of the namespaces expired.");

$manager->touch_cache($testns2);

$result = $mem->compute_from_subcache($testkey, sub {"value changed again !"});
is($result, "value changed again !", 
    "Value is properly recompute_from_subcached when on of the namespaces expired.");


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



