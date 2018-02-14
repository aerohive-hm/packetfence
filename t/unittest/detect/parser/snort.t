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

use Test::More tests => 5;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use_ok('pf::factory::detect::parser');

my $alert = '07/28/2015-09:09:59.431113  [**] [1:2221002:1] SURICATA HTTP request field missing colon [**] [Classification: Generic Protocol Command Decode] [Priority: 3] {TCP} 10.220.10.186:44196 -> 199.167.22.51:8000';
 
my $parser = pf::factory::detect::parser->new('snort');
my $result = $parser->parse($alert);

is($result->{srcip}, "10.220.10.186");
is($result->{events}->{detect}, "2221002");
is($result->{events}->{suricata_event}, "SURICATA HTTP request field missing colon");

#This test will running last
use Test::NoWarnings;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
