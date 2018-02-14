#!/usr/bin/perl

=head1 NAME

Move source associated to a realm to realms associated to a source 

=cut

=head1 DESCRIPTION

Moved realms to authentication.conf that was defined in realm.conf

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::IniFiles;
use pf::file_paths qw($authentication_config_file $realm_config_file);
use pf::authentication;

exit 0 unless -e $realm_config_file;
exit 0 unless -e $authentication_config_file;

my $inirealm =
  pf::IniFiles->new( -file => $realm_config_file, -allowempty => 1 );

my $iniauth =
  pf::IniFiles->new( -file => $authentication_config_file, -allowempty => 1 );

for my $section ( $inirealm->Sections() ) {
    next if $section =~ / /;
    next unless $inirealm->exists( $section, 'source' );
    my $source = $inirealm->val( $section, 'source' );

    for my $authsection ( $iniauth->Sections() ) {
        if ($authsection eq $source) {
            if (my $previous = $iniauth->val($authsection, 'realms')) {
                $iniauth->setval($authsection, 'realms', lc($section).",$previous");
            } else {
                $iniauth->newval($authsection, 'realms', lc($section));
            }
        }
    }
    $inirealm->delval($section, 'source');
}

for my $authsection ( $iniauth->Sections() ) {
    next if $authsection =~ / /;
    my $source_def = pf::authentication::getAuthenticationSource($authsection);
    if ( defined($iniauth->val($authsection, 'type')) && $iniauth->val($authsection, 'type') eq 'Kerberos') {
        if (defined($iniauth->val( $authsection, 'realms'))) {
            $iniauth->newval($authsection, 'authenticate_realm', $iniauth->val( $authsection, 'realm'));
            $iniauth->setval($authsection, 'realms', 'null');
        }
    }
    if ($source_def->class eq 'internal') {
         if (!defined($iniauth->val( $authsection, 'realms')) || $iniauth->val( $authsection, 'realms') eq '') {
             $iniauth->setval( $authsection, 'realms', 'null');
         }
    }
}

$inirealm->RewriteConfig();
$iniauth->RewriteConfig();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut
