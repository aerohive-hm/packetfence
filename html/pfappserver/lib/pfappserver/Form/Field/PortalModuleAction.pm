package pfappserver::Form::Field::PortalModuleAction;

=head1 NAME

pfappserver::Form::Field::PortalModuleAction - an action for the portal modules

=head1 DESCRIPTION

This is to create an action for a portal module

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';
use namespace::autoclean;

use pf::config;
use pfconfig::namespaces::config::PortalModules;

has '+do_wrapper' => ( default => 1 );
has '+do_label' => ( default => 1 );
has '+inflate_default_method'=> ( default => sub { \&action_inflate } );
has '+deflate_value_method'=> ( default => sub { \&action_deflate } );
has '+wrapper_class' => (builder => 'action_wrapper_class');

sub action_wrapper_class {[qw(compound-input-btn-group)] }

has_field 'type' =>
  (
   type => 'Select',
   do_label => 0,
   required => 1,
   widget_wrapper => 'None',
   default => 'Select an option',
  );
has_field 'arguments' =>
  (
   type => 'Hidden',
   do_label => 0,
   widget_wrapper => 'None',
   element_class => ['input-medium'],
  );

=head2 action_inflate

Inflate an action of the format :
  action(arg1,arg2,arg3)

=cut

sub action_inflate {
    my ($self, $value) = @_;
    my $hash = {};
    if (defined $value) {
        @{$hash}{'type', 'arguments'} = pfconfig::namespaces::config::PortalModules::inflate_action($value);
        $hash->{arguments} = join(',',@{$hash->{arguments}});
    }
    return $hash;
}

=head2 action_inflate

Deflate an action to the format :
  action(arg1;arg2;arg3)

=cut

sub action_deflate {
    my ($self, $value) = @_;
    my $type = $value->{type};
    my $joined_arguments = $value->{arguments};
    return "${type}(${joined_arguments})";
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
