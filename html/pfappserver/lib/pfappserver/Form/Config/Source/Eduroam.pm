package pfappserver::Form::Config::Source::Eduroam;

=head1 NAME

pfappserver::Form::Config::Source::Eduroam

=cut

=head1 DESCRIPTION

Form definition to create or update an Eduroam authentication source.

=cut

use strict;
use warnings;

use pf::config qw( %Config );

use HTML::FormHandler::Moose;

extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';

has_field 'server1_address' => (
    type        => 'Text',
    label       => 'Server 1 address',
    required    => 1,
    # Default value needed for creating dummy source
    default     => "",
    tags        => {
        after_element   => \&help,
        help            => 'Eduroam server 1 address',
    },
);

has_field 'server2_address' => (
    type        => 'Text',
    label       => 'Server 2 address',
    required    => 1,
    # Default value needed for creating dummy source
    default     => "",
    tags        => {
        after_element   => \&help,
        help            => 'Eduroam server 2 address',
    },
);

has_field 'radius_secret' => (
    type        => 'Text',
    label       => 'RADIUS secret',
    required    => 1,
    # Default value needed for creating dummy source
    default     => "",
    tags        => {
        after_element   => \&help,
        help            => 'Eduroam RADIUS secret',
    },
);

has_field 'auth_listening_port' => (
    type            => 'PosInteger',
    label           => 'Authentication listening port',
    tags            => {
        after_element   => \&help,
        help            => 'PacketFence Eduroam RADIUS virtual server authentication listening port',
    },
    element_attr    => {
        placeholder     => pf::Authentication::Source::EduroamSource->meta->get_attribute('auth_listening_port')->default,
    },
    default         => pf::Authentication::Source::EduroamSource->meta->get_attribute('auth_listening_port')->default,
);


has_field 'reject_realm' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Reject Realms',
   options_method => \&options_realm,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add a realm'},
   tags => { after_element => \&help,
             help => 'Realms that will be rejected' },
   default => '',
  );

has_field 'local_realm' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Local Realms',
   options_method => \&options_realm,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to add a realm'},
   tags => { after_element => \&help,
             help => 'Realms that will be authenticate locally' },
   default => '',
  );

has_field 'monitor',
  (
   type => 'Toggle',
   label => 'Monitor',
   checkbox_value => '1',
   unchecked_value => '0',
   tags => { after_element => \&help,
             help => 'Do you want to monitor this source?' },
   default => pf::Authentication::Source::EduroamSource->meta->get_attribute('monitor')->default,
);

sub options_realm {
    my $self = shift;
    my @roles = map { $_ => $_ } sort keys %pf::config::ConfigRealm;
    return @roles;
}

=head2 getSourceArgs

get the args to build a source

=cut

sub getSourceArgs {
    my ($self) = @_;
    my $args = $self->SUPER::getSourceArgs();
    for my $r (qw(local_realm reject_realm)) {
        $args->{$r} //= [];
        if (ref($args->{$r}) ne "ARRAY" ) {
            $args->{$r} = [$args->{$r}];
        }
    }
    return $args;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

