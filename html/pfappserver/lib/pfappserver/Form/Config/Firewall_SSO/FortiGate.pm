package pfappserver::Form::Config::Firewall_SSO::FortiGate;

=head1 NAME

pfappserver::Form::Config::Firewall_SSO::FortiGate - Web form to add a Fortigate firewall

=head1 DESCRIPTION

Form definition to create or update a Fortigate firewall.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Firewall_SSO';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);

## Definition
has 'roles' => (is => 'ro', default => sub {[]});

has_field 'id' =>
  (
   type => 'Text',
   label => 'Hostname or IP Address',
   required => 1,
   messages => { required => 'Please specify the hostname or IP of the firewall' },
  );
has_field 'password' =>
  (
   type => 'ObfuscatedText',
   label => 'Secret or Key',
   required => 1,
   messages => { required => 'You must specify the password or the key' },
  );
has_field 'port' =>
  (
   type => 'PosInteger',
   label => 'Port of the service',
   default => 1813,
   tags => { after_element => \&help,
             help => 'If you use an alternative port, please specify' },
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );
has_field 'categories' =>
  (
   type => 'Select',
   multiple => 1,
   label => 'Roles',
   options_method => \&options_categories,
   element_class => ['chzn-select'],
   element_attr => {'data-placeholder' => 'Click to add a role'},
   tags => { after_element => \&help,
             help => 'Nodes with the selected roles will be affected' },
  );

has_block definition =>
  (
   render_list => [ qw(id type password port categories networks cache_updates cache_timeout username_format default_realm) ],
  );

=head2 options_categories

=cut

sub options_categories {
    my $self = shift;

    my ($status, $result) = $self->form->ctx->model('Config::Roles')->listFromDB();
    my @roles = map { $_->{name} => $_->{name} } @{$result} if ($result);
    return ('' => '', @roles);
}


=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
