package pfappserver::Form::Config::Source::Kerberos;

=head1 NAME

pfappserver::Form::Config::Source::Kerberos - Web form for a Kerberos user source

=head1 DESCRIPTION

Form definition to create or update a Kerberos user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help', 'pfappserver::Base::Form::Role::InternalSource';

# Form fields
has_field 'host' =>
  (
   type => 'Text',
   label => 'Host',
   required => 1,
   # Default value needed for creating dummy source
   default => "",
   element_class => ['input-small'],
   element_attr => {'placeholder' => '127.0.0.1'},
  );
has_field 'authenticate_realm' =>
  (
   type => 'Text',
   label => 'Realm to use to authenticate',
   required => 1,
   # Default value needed for creating dummy source
   default => "",
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
