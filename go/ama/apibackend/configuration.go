package apibackend

import (
	"github.com/inverse-inc/packetfence/go/ama/apibackend/configuration"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

func init() {
	sections := crud.Sections{
		"cloud":         configuration.CloudNew,
		"interface":     configuration.InterfaceNew,
		"license":       configuration.LicenseNew,
		"cluster":       configuration.ClusterNew,
		"clusterremove": configuration.ClusterRemoveNew,
		"clusterstatus": configuration.StatusNew,
	}
	Register("configuration", sections)
}
