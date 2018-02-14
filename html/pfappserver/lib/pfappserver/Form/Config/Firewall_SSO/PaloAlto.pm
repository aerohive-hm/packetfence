package pfappserver::Form::Config::Firewall_SSO::PaloAlto;

=head1 NAME

pfappserver::Form::Config::Firewall_SSO::PaloAlto - Web form for a floating device

=head1 DESCRIPTION

Form definition to create or update a floating network device.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Firewall_SSO';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);
use pf::constants::firewallsso qw($SYSLOG_TRANSPORT $HTTP_TRANSPORT);

## Definition
has 'roles' => (is => 'ro', default => sub {[]});

has_field 'id' =>
  (
   type => 'Text',
   label => 'Hostname or IP Address',
   required => 1,
   messages => { required => 'Please specify the hostname or IP of the Firewall' },
  );

has_field 'transport' =>
  (
   type => 'Select',
   options => [{ label => 'Syslog', value => $SYSLOG_TRANSPORT }, { label => 'HTTP' , value => $HTTP_TRANSPORT }],
   default => $HTTP_TRANSPORT,
  );

has_field 'password' =>
  (
   type => 'ObfuscatedText',
   label => 'Secret or Key',
   tags => { after_element => \&help,
             help => 'If using the HTTP transport, specify the password for the Palo Alto API' },
  );
has_field 'port' =>
  (
   type => 'PosInteger',
   label => 'Port of the service',
   tags => { after_element => \&help,
             help => 'If you use an alternative port, please specify. This parameter is ignored when the Syslog transport is selected.' },
    default => 443,
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

has_field 'vsys' =>
  (
   type => 'PosInteger',
   label => 'Vsys ',
    tags => { after_element => \&help,
             help => 'Please define the Virtual System number. This only has an effect when used with the HTTP transport.' },
   default => 1,
  );

has_block definition =>
  (
   render_list => [ qw(id type vsys transport port password categories networks cache_updates cache_timeout username_format default_realm) ],
  );


=head2 Methods

=cut

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
