package pf::factory::scan;

=head1 NAME

pf::factory::scan

=cut

=head1 DESCRIPTION

pf::factory::scan

The factory for creating pf::scan objects

=cut

use strict;
use warnings;
use Module::Pluggable
  search_path => 'pf::scan',
  sub_name    => 'modules',
  require     => 1,
  inner       => 0,
  except      => qr/^pf::scan::wmi::(.*)$/;
use List::MoreUtils qw(any);
use pf::scan;
use pf::config qw(
    %ConfigScan
);

our @MODULES = __PACKAGE__->modules;

sub factory_for { 'pf::scan' }

sub new {
    my ($class,$name) = @_;
    my $object;
    my $data = $ConfigScan{$name};
    $data->{id} = $name;
    if ($data) {
        my $subclass = $class->getModuleName($name,$data);
        $object = $subclass->new(%$data);
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

