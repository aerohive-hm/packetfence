package pf::UnifiedApi::GenerateSpec;

=head1 NAME

pf::UnifiedApi::GenerateSpec - Auto generate the spec

=cut

=head1 DESCRIPTION

pf::UnifiedApi::GenerateSpec

=cut

use strict;
use warnings;
our %FIELDS_TYPES_TO_SCHEMA_TYPES = (
    PosInteger => 'integer',
);
use Lingua::EN::Inflexion qw(noun);

sub formHandlerToSchema {
    my ($form) = @_;
    my $name = ref $form;
    $name =~ s/^.*:://;
    return {
        $name => objectSchema($form),
        "${name}List" => listSchema($name)
    };
}

sub subTypesSchema {
    my (@forms) = @_;
    return {
        oneOf => [
            map { objectSchema($_) } @forms
        ],
        discriminator => {
            propertyName => 'type',
        }
    }
}

sub formsToSchema {
    my ($forms) = @_;
    if (@$forms == 1) {
        return objectSchema(@$forms);
    }

    return subTypesSchema(@$forms);

}

sub objectSchema {
    my ($form) = @_;
    return {
        type       => 'object',
        properties => formHandlerProperties($form),
        required   => formHandlerRequiredProperties($form),
    }
}

sub formHandlerRequiredProperties {
    my ($form) = @_;
    return [map { $_->name } grep { isRequiredField($_) } $form->fields];
}

sub formHandlerProperties {
    my ($form) = @_;
    my %properties;
    for my $field (grep { isAllowedField($_) } $form->fields) {
        my $name = $field->name;
        $properties{$name} = fieldProperties($field);
    }

    return \%properties;
}

sub fieldProperties {
    my ($field, $not_array) = @_;
    my %props = (
        type => fieldType($field, $not_array),
        description => fieldDescription($field),
    );
    if ($props{type} eq 'array') {
        $props{items} = fieldArrayItems($field);
    } elsif ($props{type} eq 'object') {
        $props{properties} = formHandlerProperties($field);
    }

    return \%props;
}

sub fieldArrayItems {
    my ($field) = @_;
    if ($field->isa('HTML::FormHandler::Field::Repeatable')) {
        $field->init_state;
        my $element = $field->clone_element(noun($field->name)->singular);
        return fieldProperties($element);
    }

    return fieldProperties($field, 1);
}

sub fieldType {
    my ($field, $not_array) = @_;
    if (isArrayType($field, $not_array)) {
        return 'array';
    }

    if (isObjectType($field)) {
        return 'object';
    }

    my $type = $field->type;
    if (exists $FIELDS_TYPES_TO_SCHEMA_TYPES{$type}) {
        return $FIELDS_TYPES_TO_SCHEMA_TYPES{$type};
    }
    return "string";
}

sub isArrayType {
    my ($field, $not_array) = @_;
    return $field->isa('HTML::FormHandler::Field::Repeatable') || 
        ($field->isa('HTML::FormHandler::Field::Select') && $field->multiple && !$not_array );
}

sub isObjectType {
    my ($field) = @_;
    return $field->isa('HTML::FormHandler::Field::Compound');
}

sub fieldDescription {
    my ($field) = @_;
    my $description = $field->get_tag('help') || $field->label;
    return $description;
}

sub listSchema {
    my ($name) = @_;
    return {
        '$ref'     => '#/components/schemas/Iterable',
        type       => 'object',
        properties => {
            items => {
                type    => 'array',
                'items' => {
                    '$ref' => "#/components/schemas/$name"
                }
            }
        },
    };
}

sub isAllowedField {
    my ($field) = @_;
    return $field->is_active && !$field->get_tag('exclude_from_openapi');
}

sub isRequiredField {
    my ($field) = @_;
    return isAllowedField($field) && $field->required;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;
