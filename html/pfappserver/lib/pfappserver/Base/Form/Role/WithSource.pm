package pfappserver::Base::Form::Role::WithSource;

=head1 NAME

pfappserver::Base::Form::Role::MultiSource

=head1 DESCRIPTION

Role for MultiSource portal modules

=cut

use HTML::FormHandler::Moose::Role;
with 'pfappserver::Base::Form::Role::Help';

use pf::log;
use pf::constants;

after 'setup' => sub {
    my ($self) = @_;

    if($self->for_module->does('captiveportal::Role::MultiSource')){
        $self->field('multi_source_ids.contains')->options([$self->options_sources(multiple => $TRUE)]);
        $self->field('multi_source_ids')->inactive($FALSE);
    }
    else {
        $self->field('source_id')->options([$self->options_sources(multiple => $FALSE)]);

        # The multi-source field should be set to inactive so it doesn't display
        $self->field('multi_source_ids')->inactive($TRUE);
    }

};

after 'process' => sub {
    my ($self) = @_;

    if(!$self->for_module->does('captiveportal::Role::MultiSource')) {
        if(defined($self->field('source_id')->value) && ref($self->field('source_id')->value) eq "ARRAY") {
            $self->field('source_id')->value($self->field('source_id')->value->[0]);
        }
    }
};

=head2 source_fields

The fields that need to be used to display the source(s) selection

=cut

sub source_fields {
    my ($self) = @_;
    # No need to add the multi_source_ids fields as it will be taken when looking at all the dynamic tables
    return $self->for_module->does('captiveportal::Role::MultiSource') ? qw() : qw(source_id);
}

has_field 'multi_source_ids' =>
  (
    'type' => 'DynamicTable',
    'sortable' => $TRUE,
    'do_label' => $FALSE,
  );

has_field 'multi_source_ids.contains' =>
  (
    type => 'Select',
    widget_wrapper => 'DynamicTableRow',
  );


has_field 'source_id' =>
  (
   type => 'Select',
   label => 'Sources',
   options => [],
   element_class => ['chzn-select'],
   element_attr => {'data-placeholder' => 'Click to add a source'},
   tags => { after_element => \&help,
             help => 'The sources to use in the module. If no sources are specified, all the sources on the Connection Profile will be used' },
  );

sub options_sources {
    my ($self, %options) = @_;
    require pf::authentication;
    my @sources;
    my $for_module_meta = $self->for_module->meta;
    # We are dealing with a multi source module, meaning we are looking for the isa in the sources attribute
    my ($isa);
    my $sources_attr = $for_module_meta->find_attribute_by_name('sources');
    if($options{multiple} && defined $sources_attr->{isa} &&  $sources_attr->{isa} =~ /^ArrayRef\[(.*)\]/){
        $isa = $1;
    }
    else {
        $isa = $for_module_meta->find_attribute_by_name('source')->{isa};
    }
    my @splitted_isas = split(/\s*\|\s*/, $isa);
    get_logger->debug("Building options with isa : $isa");
    foreach my $source ( grep { !$_->isa("pf::Authentication::Source::AdminProxySource") } @{pf::authentication::getAllAuthenticationSources()} ){
        foreach my $splitted_isa (@splitted_isas) {
            if($source->isa($splitted_isa)){
                push @sources, $source->id;
                last;
            }
        }
    }
    get_logger->debug(sub { use Data::Dumper; "The following sources are available : ".Dumper(\@sources) });
    return map { {value => $_, label => $_} } @sources;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


