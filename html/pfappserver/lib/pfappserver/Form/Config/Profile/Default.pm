package pfappserver::Form::Config::Profile::Default;

=head1 NAME

pfappserver::Form::Config::Profile::Default

=head1 DESCRIPTION

Connection profile.

=cut

use pf::authentication;

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Form::Config::ProfileCommon';


has_field '+redirecturl' => ( required => 1 );

has_field '+logo' => ( required => 1 );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
