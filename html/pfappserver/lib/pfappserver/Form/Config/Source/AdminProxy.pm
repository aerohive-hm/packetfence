package pfappserver::Form::Config::Source::AdminProxy;

=head1 NAME

pfappserver::Form::Config::Source::AdminProxy - Form for the AdminProxySource

=cut

=head1 DESCRIPTION

Form definition to create or update an AdminProxy authentication source.

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
use pf::util qw(valid_ip);
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';

has_block definition => (
    render_list => [qw(proxy_addresses user_header group_header)],
);

has_field 'proxy_addresses' => (
    type => 'TextArea',
    required => 1,
    # Default value needed for creating dummy source
    default => '',
    tags => {
        after_element => \&help,
        help => 'A comma seperated list of IP Address',
    }
);

has_field 'user_header' => (
    type => 'Text',
    required => 1,
    # Default value needed for creating dummy source
    default => '',
);

has_field 'group_header' => (
    type => 'Text',
    required => 1,
    # Default value needed for creating dummy source
    default => '',
);

=head2 validate

Validate Proxy IP Addresses

=cut

sub validate {
    my ($self) = @_;
    my $proxy_addresses_field = $self->field('proxy_addresses');
    my $proxy_addresses = $proxy_addresses_field->value;
    for my $ip (split(/\s*,\s*/, $proxy_addresses)) {
        unless (valid_ip($ip)) {
            $proxy_addresses_field->add_error("$ip is invalid");
        }
    }
    return;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
