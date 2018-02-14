package pf::factory::pki_provider;

=head1 NAME

pf::factory::pki_provider

=cut

=head1 DESCRIPTION

The factory for pki providers

=cut

use strict;
use warnings;

use List::MoreUtils qw(any);
use Module::Pluggable
  search_path => 'pf::pki_provider',
  sub_name    => 'modules',
  inner       => 0,
  require     => 1;

use pf::config qw(%ConfigPKI_Provider);

sub factory_for { 'pf::pki_provider' }

our @MODULES = __PACKAGE__->modules;

our @TYPES = map { /^pf::pki_provider::(.*)$/ ; $1 } @MODULES;

our %MODULES;
foreach ( @MODULES ) {
    my $type = $_;
    $type =~ s/^.*://;
    $MODULES{$_}{'type'} = $type;
    $MODULES{$_}{'description'} = $_->module_description || $_;
}

=head2 new

Will create a new pf::pki_provider sub class  based off the name of the provider
If no provider is found the return undef

=cut

sub new {
    my ($class,$name) = @_;
    my $object;
    my $data = $ConfigPKI_Provider{$name};
    $data->{id} = $name;
    if ($data) {
        my $subclass = $class->getModuleName($name,$data);
        $object = $subclass->new($data);
    }
    return $object;
}


=head2 getModuleName

Get the sub module pf::pki_provider base off it's configuration

=cut

sub getModuleName {
    my ($class,$name,$data) = @_;
    my $mainClass = $class->factory_for;
    my $type = $data->{type};
    my $subclass = "${mainClass}::${type}";
    die "type is not defined for $name" unless defined $type;
    die "$type is not a valid type" unless any { $_ eq $subclass  } @MODULES;
    $subclass;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

