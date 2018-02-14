package pfappserver::Form::Config::Source::AD;

=head1 NAME

pfappserver::Form::Config::Source::AD - Web form for a AD user source

=head1 DESCRIPTION

Form definition to create or update a Active Directory user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source::LDAP';


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
