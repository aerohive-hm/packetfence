package pf::Authentication::Source::NullSource;
=head1 NAME

pf::Authentication::Source::NullSource add documentation

=cut

=head1 DESCRIPTION

pf::Authentication::Source::NullSource

=cut

use strict;
use warnings;
use Moose;
use pf::constants;
use pf::constants::authentication::messages;
use pf::config;
use Email::Valid;
use pf::util;

extends 'pf::Authentication::Source';

has '+class' => (default => 'external');
has '+type' => (default => 'Null');
has 'email_required' => (isa => 'Str', is => 'rw', default => 'no');

=head2 authenticate

=cut

sub authenticate {
  my $self = shift;
  return $TRUE;
}

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::Null' }

=head2 available_attributes

Allow to make a condition on the user's email address.

=cut

sub available_attributes {
  my $self = shift;

  my $super_attributes = $self->SUPER::available_attributes;
  my $own_attributes = [{ value => "username", type => $Conditions::SUBSTRING }];

  return [@$super_attributes, @$own_attributes];
}

=head2 available_rule_classes

Null sources only allow 'authentication' rules

=cut

sub available_rule_classes {
    return [ grep { $_ ne $Rules::ADMIN } @Rules::CLASSES ];
}

=head2 available_actions

For a Null source, only the authentication actions should be available

=cut

sub available_actions {
    my @actions = map( { @$_ } $Actions::ACTIONS{$Rules::AUTH});
    return \@actions;
}

=head2 match_in_subclass

=cut

sub match_in_subclass {
    my ($self, $params, $rule, $own_conditions, $matching_conditions) = @_;
    my $username =  $self->email_required ? $params->{'username'} : $default_pid;
    foreach my $condition (@{ $own_conditions }) {
        if ($condition->{'attribute'} eq "username") {
            if ( $condition->matches("username", $username) ) {
                push(@{ $matching_conditions }, $condition);
            }
        }
    }
    return $username;
}

=head2 mandatoryFields

=cut

sub mandatoryFields {
    my ($self) = @_;
    if (isenabled($self->email_required)) {
        return (qw(email));
    }
    return ();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

