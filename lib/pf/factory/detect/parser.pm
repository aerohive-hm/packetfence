package pf::factory::detect::parser;

=head1 NAME

pf::factory::detect::parser

=cut

=head1 DESCRIPTION

pf::factory::detect::parser

Create a pfdetect parser by it's configuration ID

=cut

use strict;
use warnings;
use Module::Pluggable
  search_path => 'pf::detect::parser',
  sub_name    => 'modules',
  inner       => 0,
  require     => 1;
use List::MoreUtils qw(any);
use pf::detect::parser;
use pf::config qw(%ConfigDetect);

our @MODULES = __PACKAGE__->modules;

sub factory_for { 'pf::detect::parser' }

sub new {
    my ($class,$name) = @_;
    my $object;
    my $data = $ConfigDetect{$name};
    if ($data) {
        $data->{id} = $name;
        my $subclass = $class->getModuleName($name,$data);
        $object = $subclass->new($data);
    }
    return $object;
}

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

