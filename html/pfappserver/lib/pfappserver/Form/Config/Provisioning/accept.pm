package pfappserver::Form::Config::Provisioning::accept;

=head1 NAME

pfappserver::Form::Config::Provisioning::accept - Web form for accept provisioner

=head1 DESCRIPTION

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
