package apibackend

import (
	"github.com/inverse-inc/packetfence/go/ama/apibackend/configurator"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

func init() {
	sections := crud.Sections{
		"admin_user":      configurator.AdminUserNew,
		"networks":        configurator.NetworksNew,
		"interface":       configurator.InterfaceNew,
		"cloud":           configurator.CloudNew,
		"license":         configurator.LicenseNew,
		"step":            configurator.StepNew,
		"servicesstatus":  configurator.ServicesNew,
		"clusterjoin":     configurator.ClusterJoinNew,
		"clusternetworks": configurator.ClusterNetworksNew,
		"clusterstatus":   configurator.ClusterStatusNew,
	}
	Register("configurator", sections)
}