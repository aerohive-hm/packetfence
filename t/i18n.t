#!/usr/bin/perl
=head1 NAME

i18n.t

=head1 DESCRIPTION

Internalization-related tests

=cut

use strict;
use warnings;
use diagnostics;

use File::Find;
use Test::More;
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

my @translations;

# find2perl /usr/local/pf/conf/locale -name "*.po"
File::Find::find({
    wanted => sub {
        /^.*\.po\z/s && push(@translations, $File::Find::name);
    }}, '/usr/local/pf/conf/locale'
);

plan tests => scalar @translations;

foreach my $translation (@translations) {
    is(
        system("/usr/bin/msgfmt -o - $translation 2>&1 >/dev/null"),
        0,
        "$translation is accepted by msgfmt"
    );
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

