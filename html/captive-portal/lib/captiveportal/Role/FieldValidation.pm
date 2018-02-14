package captiveportal::Role::FieldValidation;

=head1 NAME

captiveportal::Role::FieldValidation

=head1 DESCRIPTION

Field Validation role

=cut

use Moose::Role;

=head2 around execute_child

This will validate the required fields when a POST is made on /signup

=cut

around 'execute_child' => sub {
    my $orig = shift;
    my $self = shift;

    if($self->app->request->method eq "POST" && $self->app->request->path eq "signup"){
        if($self->handle_posted_fields()){
            return $self->$orig(@_);  
        }
        else {
            return;
        }
    }
    $self->$orig(@_);
};

=head2 validate_required_fields

Check if there are missing fields in the request based on required_fields

=cut

sub validate_required_fields {
    my ($self) = @_;
    my @errors;
    foreach my $field (@{$self->required_fields}){
        unless(defined($self->request_fields->{$field}) && $self->request_fields->{$field}){
            push @errors, $self->app->i18n(["%s is required", $self->app->i18n($field)]);
        }
    }
    return \@errors;
}

=head2 validate_form

Validate that the form fields are valid and all the required fields are there

=cut

sub validate_form {
    my ($self) = @_;

    my $errors = $self->validate_required_fields();
    if(@$errors){
        $self->app->flash->{error} = [ "The following errors prevented the request to be fulfilled : %s", join(', ', @$errors) ];
        return 0;
    }
    my $form = $self->form($self->request_fields);
    if($form->has_errors){
        my @messages;
        for my $field ($form->error_fields) {
            push @messages, map{ $field->label . ": " . $_ } @{$field->errors}; 
        }
        $self->app->flash->{error} = [ "The following errors prevented the request to be fulfilled : %s", join(', ', @messages) ];
        return 0;
    }
    return 1;
}

=head2 handle_posted_fields

Handle a POST of the fields

=cut

sub handle_posted_fields {
    my ($self) = @_;
    unless($self->validate_form()){
        $self->prompt_fields();
        return 0;
    }
    return 1;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


