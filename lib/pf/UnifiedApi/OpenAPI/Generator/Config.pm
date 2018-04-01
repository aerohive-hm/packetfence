package pf::UnifiedApi::OpenAPI::Generator::Config;

=head1 NAME

pf::UnifiedApi::OpenAPI::Generator::Config -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::OpenAPI::Generator::Config

=cut

use strict;
use warnings;
use Module::Load;
use Moo;
use pf::UnifiedApi::GenerateSpec;

extends qw(pf::UnifiedApi::OpenAPI::Generator);

our %METHODS_WITH_ID = (
    get  => 1,
    post => 1,
);

our %OPERATION_GENERATORS = (
    requestBody => {
        create  => "createRequestBody",
        search  => sub { undef },
        replace => "replaceRequestBody",
        update  => "updateRequestBody",
    },
    responses => {
        search  => sub { undef },
        list    => "listResponses",
        get     => "getResponses",
        replace => "replaceResponses",
        update  => "updateResponses",
        remove  => "removeResponses",
    },
    parameters => {
        (
            map { $_ => "operationParameters" }
              qw(create search list get replace update remove)
        )
    },
    description => {
        (
            map { $_ => "operationDescription" }
              qw(create search list get replace update remove)
        )
    },
    operationId => {
        (
            map { $_ => "operationId" }
              qw(create search list get replace update remove)
        )
    }
);

sub operation_generators {
    \%OPERATION_GENERATORS;
}

sub createResponses {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return undef;
}

sub listResponses {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return undef;
}

sub getResponses {
    my ( $self, $scope, $c, $m, $a ) = @_;
    my @forms = buildForms( $c, $a, $m );
    return {
        "200" => {
            "content" => {
                "application/json" => {
                    configCollectionPostJsonSchema( $m, $a, \@forms )
                },
            }
        },
        "400" => {
            "\$ref" => "#/components/responses/BadRequest"
        },
        "422" => {
            "\$ref" => "#/components/responses/UnprocessableEntity"
        }
    };
}

sub replaceResponses {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return {
        "201" => {
            "\$ref" => "#/components/responses/Created"
        },
        "400" => {
            "\$ref" => "#/components/responses/BadRequest"
        },
        "422" => {
            "\$ref" => "#/components/responses/UnprocessableEntity"
        }
    };
}

sub updateResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub removeResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return {
        '204' => {
            description => 'Deleted a config item'
        }
    };
}

sub configCollectionPostJsonSchema {
    my ( $method, $child, $forms ) = @_;
    return "schema" => pf::UnifiedApi::GenerateSpec::formsToSchema($forms);
}

sub buildForms {
    my ( $controller, $child, $m ) = @_;
    my @form_classes;
    if ( $controller->can("type_lookup") ) {
        @form_classes = values %{ $controller->type_lookup };
    }
    else {
        my $form_class = $controller->form_class;
        return if $form_class eq 'pfappserver::Form::Config::Pf';
        @form_classes = ( $controller->form_class );
    }

    my @form_parameters =
      ( !exists $METHODS_WITH_ID{$m} ) ? ( inactive => ['id'] ) : ();
    return map { $_->new(@form_parameters) } @form_classes;
}

sub operationId {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return $a->{operationId};
}

sub createRequestBody {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return $self->requestBody( $scope, $c, $m, $a );
}

sub replaceRequestBody {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return $self->requestBody( $scope, $c, $m, $a );
}

sub updateRequestBody {
    my ( $self, $scope, $c, $m, $a ) = @_;
    return $self->requestBody( $scope, $c, $m, $a );
}

sub requestBody {
    my ( $self, $scope, $c, $m, $a ) = @_;
    my @forms = buildForms( $c, $a, $m );
    return {
        "content" => {
            "application/json" => { 
                configCollectionPostJsonSchema( $m, $a, \@forms )
            },
        }
    };
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
