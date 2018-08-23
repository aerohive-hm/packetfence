//pfget.go implements get pfconf element data.
package utils

import (
	//"context"
	//"fmt"
	//"strings"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	//"github.com/inverse-inc/packetfence/go/log"
)

func GetHostname() string {
	section := a3config.A3Read("PF", "general")
	if section == nil {
		return ""
	}
	return section["general"]["hostname"]
}

func GetWebServices() a3config.Section {
	return a3config.A3Read("PF", "webservices")
}

func ReadIface(ifname string) a3config.Section {
	if ifname != "all" {
		return a3config.A3Read("PF", ifname)
	}
	return nil
}
