package pfappserver::Form::Config::Realm;

=head1 NAME

pfappserver::Form::Config::Realm - Web form for a floating device

=head1 DESCRIPTION

Form definition to create or update realm.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::authentication;
use pf::util;

has domains => ( is => 'rw');

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'Realm',
   required => 1,
   messages => { required => 'Please specify a Realm' },
   apply => [ pfappserver::Base::Form::id_validator('realm') ]
  );

has_field 'options' =>
  (
   type => 'TextArea',
   label => 'Realm Options',
   required => 0,
   tags => { after_element => \&help,
             help => 'You can add options in the realm definition' },
  );

has_field 'domain' =>
  (
   type => 'Select',
   multiple => 0,
   label => 'Domain',
   options_method => \&options_domains,
   element_class => ['chzn-deselect'],
   element_attr => {'data-placeholder' => 'Click to select a domain'},
   tags => { after_element => \&help,
             help => 'The domain to use for the authentication in that realm' },
  );

=head2 options_roles

=cut

sub options_domains {
    my $self = shift;
    my @domains = map { $_->{id} => $_->{id} } @{$self->form->domains} if ($self->form->domains);
    unshift @domains, ("" => "");
    return @domains;
}

=head2 ACCEPT_CONTEXT

To automatically add the context to the Form

=cut

sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    my (undef, $domains) = $c->model('Config::Domain')->readAll();
    return $self->SUPER::ACCEPT_CONTEXT($c, domains => $domains, @args);
}


=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
