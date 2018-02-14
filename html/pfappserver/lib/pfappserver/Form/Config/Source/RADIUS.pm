package pfappserver::Form::Config::Source::RADIUS;

=head1 NAME

pfappserver::Form::Config::Source::RADIUS - Web form for a Kerberos user source

=head1 DESCRIPTION

Form definition to create or update a RADIUS user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help', 'pfappserver::Base::Form::Role::InternalSource';

# Form fields
has_field 'host' =>
  (
   type => 'Text',
   label => 'Host',
   element_class => ['input-small'],
   element_attr => {'placeholder' => '127.0.0.1'},
   default => '127.0.0.1',
   required => 1,
  );
has_field 'port' =>
  (
   type => 'PosInteger',
   label => 'Port',
   element_class => ['input-mini'],
   element_attr => {'placeholder' => '1812'},
   default => 1812,
   required => 1,
  );
has_field 'secret' =>
  (
   type => 'ObfuscatedText',
   label => 'Secret',
   required => 1,
   # Default value needed for creating dummy source
   default => '',
  );
has_field 'timeout' =>
  (
   type => 'PosInteger',
   label => 'Timeout',
   required => 1,
   element_class => ['input-mini'],
   element_attr => {'placeholder' => '1'},
   default => 1,
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
