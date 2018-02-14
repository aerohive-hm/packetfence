package pfappserver::Form::User::Create::Single;

=head1 NAME

pfappserver::Form::User::Create::Single - Single user account creation

=head1 DESCRIPTION

Form to create a single user account.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

# Form fields
has_field 'pid' =>
  (
   type => 'Text',
   label => 'Username',
   required => 1,
   tags => { after_element => \&help,
             help => 'The username to use for login to the captive portal.' },
  );
has_field 'pid_overwrite' => (
    type    => 'Checkbox',
    label   => 'Username (PID) overwrite',
    tags    => {
        after_element   => \&help,
        help            => 'Overwrite the username (PID) if it already exists',
    },
);
has_field 'password' =>
  (
   type => 'Password',
   label => 'Password',
   tags => { after_element => \&help,
             help => 'Leave it empty if you want to generate a random password.' },
  );
has_field 'firstname' =>
  (
   type => 'Text',
   label => 'Firstname',
  );
has_field 'lastname' =>
  (
   type => 'Text',
   label => 'Lastname',
  );
has_field 'company' =>
  (
   type => 'Text',
   label => 'Company',
  );
has_field 'telephone' =>
  (
   type => 'Text',
   label => 'Telephone',
  );
has_field 'email' =>
  (
   type => 'Email',
   label => 'Email',
   required => 1,
  );
has_field 'address' =>
  (
   type => 'TextArea',
   label => 'Address',
  );
has_field 'notes' =>
  (
   type => 'TextArea',
   label => 'Notes',
  );
has_field 'login_remaining' =>
  (
   type => 'PosInteger',
   label => 'Login remaining',
   default => undef,
   tags => { after_element => \&help,
             help => 'Leave it empty to allow unlimited logins.' },
  );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;
