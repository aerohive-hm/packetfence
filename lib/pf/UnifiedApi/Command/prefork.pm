package pf::UnifiedApi::Command::prefork;

=head1 NAME

pf::UnifiedApi::Command::prefork - Pre-fork command

=cut

use Systemd::Daemon qw {-soft };
use Mojo::Base qw(Mojolicious::Command::prefork);

sub run {
  my ($self, @args) = @_;
  Systemd::Daemon::notify( READY => 1, STATUS => "Ready", unset => 1 );
  eval {
    $self->SUPER::run(@args);
  };
  if ($@) {
      print STDERR $@;
  }
  Systemd::Daemon::notify( STOPPING => 1 );
}

1;

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut
