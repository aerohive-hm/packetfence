package pfappserver::Form::Config::Provisioning::jamf;

=head1 NAME

pfappserver::Form::Config::Provisioning::jamf

=head1 DESCRIPTION

Web form for a JAMF provisioner

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';
with 'pfappserver::Base::Form::Role::Help';

use pf::constants;

has_field 'host' => (
    type => 'Text',
);

has_field 'port' => (
    type        => 'PosInteger',
    required    => $TRUE,
    default     => $HTTPS_PORT,
);

has_field 'protocol' => (
    type    => 'Select',
    options => [ { label => $HTTP, value => $HTTP }, { label => $HTTPS , value => $HTTPS } ],
    default => $HTTPS,
);

has_field 'api_username' => (
    type        => 'Text',
    label       => 'API username',
    required    => $TRUE,
);

has_field 'api_password' => (
    type        => 'ObfuscatedText',
    label       => 'API password',
    required    => $TRUE,
);

has_field 'device_type_detection' => (
    type            => 'Toggle',
    label           => 'Automatic device detection',
    checkbox_value  => 'enabled',
    unchecked_value => 'disabled',
    default         => 'disabled',
);

has_field 'query_computers' => (
    type            => 'Toggle',
    label           => 'Query JAMF computers inventory',
    checkbox_value  => 'enabled',
    unchecked_value => 'disabled',
    default         => 'enabled',
);

has_field 'query_mobiledevices' => (
    type            => 'Toggle',
    label           => 'Query JAMF mobile devices inventory',
    checkbox_value  => 'enabled',
    unchecked_value => 'disabled',
    default         => 'enabled',
);

has_block definition => (
    render_list => [ qw(id type description category oses host port protocol api_username api_password device_type_detection query_computers query_mobiledevices) ],
);

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
