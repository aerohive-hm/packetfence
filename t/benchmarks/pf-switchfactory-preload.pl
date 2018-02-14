#!/usr/bin/perl
#
=head1 NAME

pf-switchfactory-preload -

=cut

=head1 DESCRIPTION

pf-switchfactory-preload

=cut

use strict;
use warnings;
use Benchmark qw(timethese);
use Module::Load;

use lib qw(/usr/local/pf/lib);

BEGIN {
    use File::Spec::Functions qw(catfile catdir rel2abs);
    use pf::file_paths;
    my $test_dir ||= catdir($install_dir,'t');
    $pf::file_paths::switches_config_file = catfile($test_dir,'data/all-switch-types.conf');
    use pf::SwitchFactory;
}
use pfconfig::manager;
pfconfig::manager->new->expire_all;
pf::SwitchFactory->preloadConfiguredModules() if $ARGV[0];

my @SWITCHES = (keys %pf::SwitchFactory::SwitchConfig);

timethese(
    1,
    {   "Preloaded" => sub {
            foreach my $key (@SWITCHES) {
                my $switch = pf::SwitchFactory->instantiate($key);
            }
          },
    }
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

