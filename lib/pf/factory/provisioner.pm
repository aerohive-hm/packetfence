package pf::factory::provisioner;

=head1 NAME

pf::factory::provisioner add documentation

=cut

=head1 DESCRIPTION

pf::factory::provisioner

=cut

use strict;
use warnings;
use Module::Pluggable
  search_path => 'pf::provisioner',
  sub_name    => 'modules',
  inner       => 0,
  require     => 1;
use List::MoreUtils qw(any);
use pf::provisioner;
use pf::config qw(%ConfigProvisioning);

our @MODULES = __PACKAGE__->modules;

sub factory_for { 'pf::provisioner' }

sub new {
    my ($class,$name) = @_;
    my $object;
    my $data = $ConfigProvisioning{$name};
    $data->{id} = $name;
    if ($data) {
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

