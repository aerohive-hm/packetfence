package pf::ConfigStore::Syslog;

=head1 NAME

pf::ConfigStore::Syslog

=cut

=head1 DESCRIPTION

pf::ConfigStore::Syslog

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moo;
use namespace::autoclean;
use pf::constants::syslog;
use pf::util qw(isenabled);
use pf::file_paths qw($syslog_config_file $syslog_default_config_file);
extends 'pf::ConfigStore';

sub configFile { $syslog_config_file }

sub importConfigFile { $syslog_default_config_file }

sub pfconfigNamespace { 'config::Syslog' }

=head2 cleanupAfterRead

Clean up switch data

=cut

sub cleanupAfterRead {
    my ($self, $id, $data) = @_;
    my $logs = $data->{logs};
    if (defined $logs && $logs eq 'ALL') {
        $data->{logs} = $pf::constants::syslog::ALL_LOGS;
        $data->{all_logs} = 'enabled';
    }
    $self->expand_list($data, $self->_fields_expanded);
}

=head2 cleanupBeforeCommit

Clean data before update or creating

=cut

sub cleanupBeforeCommit {
    my ($self, $id, $data) = @_;
    my $all_logs = delete $data->{all_logs};
    if (isenabled ($all_logs)) {
        $data->{logs} = 'ALL';
    }
    $self->flatten_list($data, $self->_fields_expanded);
}

=head2 _fields_expanded

=cut

sub _fields_expanded {
    return qw(logs);
}

__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
