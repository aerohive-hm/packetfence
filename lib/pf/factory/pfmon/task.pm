package pf::factory::pfmon::task;

=head1 NAME

pf::factory::pfmon::task -

=cut

=head1 DESCRIPTION

pf::factory::pfmon::task

=cut

use strict;
use warnings;
use List::MoreUtils qw(any);
use Module::Pluggable
  search_path => 'pf::pfmon::task',
  sub_name    => 'modules',
  inner       => 0,
  require     => 1;

use pf::config::pfmon qw(%ConfigPfmon);

sub factory_for { 'pf::pfmon::task' }

our @MODULES = __PACKAGE__->modules;

our @TYPES = map { /^pf::pfmon::task::(.*)$/ ; $1 } @MODULES;

=head2 new

Will create a new pf::pfmon::task sub class  based off the name of the task
If no task is found the return undef

=cut

sub new {
    my ($class, $name, $additional) = @_;
    my $object;
    my $data = $ConfigPfmon{$name};
    if ($data) {
        %$data = (%$data, %{ $additional // {}});
        $data->{id} = $name;
        my $subclass = $class->getModuleName($name,$data);
        $object = $subclass->new($data);
    }
    return $object;
}


=head2 getModuleName

Get the sub module pf::pfmon::task base off it's configuration

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
