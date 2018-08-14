package apibackend

import (
	"github.com/inverse-inc/packetfence/go/ama/apibackend/configurator"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

func init() {
	sections := crud.Sections{
		"admin_user":       configurator.AdminUserNew,
		"cluster/networks": configurator.NetworksCmdNew,
	}
	Register("configurator", sections)
}
