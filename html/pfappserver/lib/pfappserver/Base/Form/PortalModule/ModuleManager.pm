package pfappserver::Base::Form::PortalModule::ModuleManager;

=head1 NAME

pfappserver::Base::Form::Role::MultiSource

=head1 DESCRIPTION

Role for MultiSource portal modules

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::PortalModule';
with 'pfappserver::Base::Form::Role::Help';

use pf::ConfigStore::PortalModule;
use captiveportal::util;

has_field 'modules' =>
  (
    'type' => 'DynamicTable',
    'sortable' => 1,
    'do_label' => 0,
  );

has_field 'modules.contains' =>
  (
    type => 'Select',
    widget_wrapper => 'DynamicTableRow',
  );


has_block 'module_manager_definition' => (
    render_list => [qw(modules)],
);

sub BUILD {
    my ($self) = @_;
    
    $self->field('modules.contains')->options([$self->options_modules]);
}

sub options_modules {
    my ($self) = @_;
    my $cs = pf::ConfigStore::PortalModule->new;
    my $modules = $cs->readAll("id");

    my $modules_by_type = captiveportal::util::modules_by_type($modules);
    delete $modules_by_type->{Root};

    return map { {
        group => $_,
        options => [
            map { {
                value => $_->{id},
                label => $_->{id}
            } } @{$modules_by_type->{$_}}
        ]
    } } keys(%$modules_by_type);
}

=head2 validate_modules

Validates that there is no cycle in the portal module before saving it.

=cut

sub validate_modules {
    my ($self, $field) = @_;
    require captiveportal::DynamicRouting::Application;
    require pf::Connection::ProfileFactory;
    require captiveportal::DynamicRouting::Factory;
    my $current_module_id = $self->field('id')->value;
    my $app = captiveportal::DynamicRouting::Application->new(user_session => {}, session => {}, profile => pf::Connection::ProfileFactory->instantiate("00:11:22:33:44:55"), request => $self->ctx->request, root_module_id => undef);
    my $factory = captiveportal::DynamicRouting::Factory->new(application => $app);

    # Setting the new modules list in pfconfig proxied hash since we haven't commited yet...
    $pf::config::ConfigPortalModules{$current_module_id}{modules} = $field->value;
    
    foreach my $id (@{$field->value}) {
        if($id eq $current_module_id) {
            $field->add_error("Module cannot have himself as a child");
            return;
        }
        my ($ok, $error) = $factory->check_cyclic($id);
        if(!$ok) {
            $field->add_error("Cycle detected on child module $id : $error");
            return;
        }
    }
    
    # Resetting the locally stored value to undef so it takes the one from pfconfig again
    $pf::config::ConfigPortalModules{$current_module_id}{modules} = undef;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


