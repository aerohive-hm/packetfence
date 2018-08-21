package apibackend

import (
	"github.com/inverse-inc/packetfence/go/ama/apibackend/configuration"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

func init() {
	sections := crud.Sections{
		"cloud"  :           configuration.CloudNew,
	}
	Register("configuration", sections)
}

