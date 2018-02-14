package pfappserver::Form::Config::Source::Htpasswd;

=head1 NAME

pfappserver::Form::Config::Source::Htpasswd - Web form for a htpasswd user source

=head1 DESCRIPTION

Form definition to create or update a htpasswd user source.

=cut

use HTML::FormHandler::Moose;
use pf::Authentication::Source::HtpasswdSource;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help', 'pfappserver::Base::Form::Role::InternalSource';

# Form fields
has_field 'path' =>
  (
   type => 'Path',
   label => 'File Path',
   required => 1,
   element_class => ['input-xxlarge'],
   # Default value needed for creating dummy source
   default => '',
  );

=head2 validate

Make sure the htpasswd file is readable.

=cut

sub validate {
    my $self = shift;

    $self->SUPER::validate();

    unless (-r $self->value->{path}) {
        $self->field('path')->add_error("The file is not readable by the user 'pf'.");
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
