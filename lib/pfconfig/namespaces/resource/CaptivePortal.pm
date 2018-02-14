package pfconfig::namespaces::resource::CaptivePortal;

=head1 NAME

pfconfig::namespaces::resource::CaptivePortal

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::CaptivePortal

=cut

use strict;
use warnings;
use pf::file_paths qw($install_dir);
use POSIX;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;
    $self->{config} = $self->{cache}->get_cache('config::Pf');
}

sub build {
    my ($self) = @_;
    my %Config = %{ $self->{config} };

    # CAPTIVE-PORTAL RELATED
    # Captive Portal constants
    my %CAPTIVE_PORTAL = (
        "TEMPLATE_DIR" => "$install_dir/html/captive-portal/templates",
    );

    # process pf.conf's parameter into an IP => 1 hash
    %{ $CAPTIVE_PORTAL{'loadbalancers_ip'} }
        = map { $_ => 1 } split( /\s*,\s*/, $Config{'captive_portal'}{'loadbalancers_ip'} );
    return \%CAPTIVE_PORTAL;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

