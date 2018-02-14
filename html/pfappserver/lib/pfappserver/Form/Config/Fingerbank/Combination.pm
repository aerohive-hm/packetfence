package pfappserver::Form::Config::Fingerbank::Combination;

=head1 NAME

pfappserver::Form::Config::Fingerbank::Combination

=head1 DESCRIPTION

Form definition for Fingerbank Combination

=cut

use HTML::FormHandler::Moose;

extends 'pfappserver::Base::Form';

has_field 'id' => (
    type => 'Text',
    label => 'Combination ID',
    readonly => 1,
);

has_field 'dhcp_fingerprint_id' => (
    type => 'FingerbankField',
    label => 'DHCP Fingerprint',
    fingerbank_model => "fingerbank::Model::DHCP_Fingerprint",
);

has_field 'dhcp_vendor_id' => (
    type => 'FingerbankField',
    label => 'DHCP Vendor',
    fingerbank_model => "fingerbank::Model::DHCP_Vendor",
);

has_field 'dhcp6_fingerprint_id' => (
    type => 'FingerbankField',
    label => 'DHCPv6 Fingerprint',
    fingerbank_model => "fingerbank::Model::DHCP6_Fingerprint",
);

has_field 'dhcp6_enterprise_id' => (
    type => 'FingerbankField',
    label => 'DHCPv6 Enterprise',
    fingerbank_model => "fingerbank::Model::DHCP6_Enterprise",
);

has_field 'mac_vendor_id' => (
    type => 'FingerbankField',
    label => 'MAC Vendor (OUI)',
    fingerbank_model => "fingerbank::Model::MAC_Vendor",
);

has_field 'user_agent_id' => (
    type => 'FingerbankField',
    label => 'User Agent',
    fingerbank_model => "fingerbank::Model::User_Agent",
);

has_field 'device_id' => (
    type => 'FingerbankField',
    label => 'Device',
    fingerbank_model => "fingerbank::Model::Device",
    required => 1,
);

has_field 'version' => (
    type => 'Text',
    label => 'Version',
);

has_field 'score' => (
    type => 'PosInteger',
    label => 'Score',
    required => 1,
);

has_field created_at => (
    type => 'Uneditable',
);

has_field updated_at => (
    type => 'Uneditable',
);

has_block definition => (
    render_list => [qw(dhcp_fingerprint_id dhcp_vendor_id dhcp6_fingerprint_id dhcp6_enterprise_id mac_vendor_id user_agent_id device_id version score created_at updated_at)],
);

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
