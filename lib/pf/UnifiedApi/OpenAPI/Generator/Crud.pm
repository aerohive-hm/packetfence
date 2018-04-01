package pf::UnifiedApi::OpenAPI::Generator::Crud;

=head1 NAME

pf::UnifiedApi::OpenAPI::Generator::Crud -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::OpenAPI::Generator::Crud

=cut

use strict;
use warnings;
use Moo;
extends qw(pf::UnifiedApi::OpenAPI::Generator);

our %OPERATION_GENERATORS = (
    requestBody => {
        (
            map { $_ => "${_}RequestBody" }
            qw(create search replace update)
        )
    },
    responses => {
        (
            map { $_ => "${_}Responses" }
              qw(create list get search replace update)
        )
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

my %OPERATION_DESCRIPTIONS = (
    remove  => 'Delete an item',
    create  => 'Create an item',
    list    => 'List items',
    get     => 'Get an item',
    replace => 'Replace an item',
    update  => 'Update an item',
    remove  => 'Remove an item',
);

sub operationDescriptionsLookup {
    return \%OPERATION_DESCRIPTIONS;
}

my %SQLTYPES_TO_OPENAPI = (
    BIGINT    => 'integer',
    INT       => 'integer',
    TINYINT   => 'integer',
    DOUBLE    => 'number',
    LONGBLOB  => 'string',
    TEXT      => 'string',
    VARCHAR   => 'string',
    DATETIME  => 'string',
    TIMESTAMP => 'string',
    CHAR      => 'string',
    ENUM      => 'string',
);

sub sqlTypeToOpenAPI {
    my ($type) = @_;
    if (exists $SQLTYPES_TO_OPENAPI{$type}) {
        return $SQLTYPES_TO_OPENAPI{$type};
    }

    return "string";
}

sub propertiesFromDal {
    my ($self, $dal) = @_;
    my $meta = $dal->get_meta;
    my %properties;
    while (my ($k, $v) = each %$meta) {

    }
    return \%properties;
}

=head2 getResponses

getResponses

=cut

sub getResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    my @paths = split('/', $a->{path});
    return "200" => {
        description => 'Get an item',
        content     => {
            "application/json" => {
                schema => {
                    type       => 'object',
                    properties => {
                        item => {}
                    },
                }
            },
        },
    };
}

=head2 removeResponses

removeResponses

=cut

sub removeResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return {
        '204' => {
            description => 'Item deleted',
        },
    };
}

sub createRequestBody {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub createResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub listResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub listRequestBody {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub searchRequestBody {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub searchResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub replaceRequestBody {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub replaceResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub updateRequestBody {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
}

sub updateResponses {
    my ($self, $scope, $c, $m, $a) = @_;
    return undef;
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
