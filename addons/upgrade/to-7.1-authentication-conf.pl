#!/usr/bin/perl

=head1 NAME

add_status_to_pfdetect_conf - 

=cut

=head1 DESCRIPTION

Add status to pfdetect.conf for section that do not have them

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::IniFiles;
use pf::Authentication::Source::TwilioSource;
use pf::Authentication::Source::SMSSource;
use pf::Authentication::Source::SQLSource;
use pf::file_paths qw($authentication_config_file);
my $twilio_meta = pf::Authentication::Source::TwilioSource->meta;
my $sms_meta    = pf::Authentication::Source::SMSSource->meta;
my $sql_meta    = pf::Authentication::Source::SQLSource->meta;

my %source_fields_to_update = (
    make_source_update_data(Twilio => qw(create_local_account local_account_logins pin_code_length)),
    make_source_update_data(SMS => qw(pin_code_length)),
    make_source_update_data(SQL => qw(stripped_user_name)),
);

sub make_source_update_data {
    my ( $type, @fields ) = @_;
    return unless @fields;
    my $meta = "pf::Authentication::Source::${type}Source"->meta;
    return $type =>
      { map { my $f = $_; $f => $meta->get_attribute($f)->default } @fields };
}

exit 0 unless -e $authentication_config_file;
my $ini =
  pf::IniFiles->new( -file => $authentication_config_file, -allowempty => 1 );

for my $section ( $ini->Sections() ) {
    next if $section =~ / /;
    next unless $ini->exists( $section, 'type' );
    my $type = $ini->val( $section, 'type' );
    unless ( exists $source_fields_to_update{$type} ) {
        next;
    }
    print "Updating $section\n";
    while ( my ( $k, $v ) = each %{ $source_fields_to_update{$type} } ) {
        if ( !$ini->exists( $section, $k ) ) {
            print "\tUpdating $k\n";
            $ini->newval( $section, $k, $v );
        }
    }
}

$ini->RewriteConfig();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

