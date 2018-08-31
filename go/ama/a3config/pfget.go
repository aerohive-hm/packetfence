//pfget.go implements get pfconf element data.
package a3config

import (
	//"context"
	"fmt"
	//"strings"
	//"github.com/inverse-inc/packetfence/go/ama/a3config"
	//"github.com/inverse-inc/packetfence/go/log"
)

func GetHostname() string {
	section := A3Read("PF", "general")
	if section == nil {
		return ""
	}
	return section["general"]["hostname"]
}

func GetWebServices() Section {
	return A3Read("PF", "webservices")
}

func ReadIface(ifname string) Section {
	if ifname != "all" {
		return A3Read("PF", ifname)
	}
	return nil
}

func GetDomain() string {
	section := A3Read("PF", "general")
	if section == nil {
		return ""
	}
	return section["general"]["domain"]
}

func GetPrimaryClusterVip(ifname string) string {
	var keyname, vip string

	keyname = fmt.Sprintf("CLUSTER interface %s", ifname)
	section := A3Read("CLUSTER", keyname)
	if section == nil {
		return "0.0.0.0"
	}
	vip = section[keyname]["ip"]

	if vip == "" {
		vip = "0.0.0.0"
	}
	return vip

}

func GetKeyFromSection(sectionId string, key string) string {
	section := A3ReadFull("PF", sectionId)
	if section == nil {
		return ""
	}
	return section[sectionId][key]
}

func ReadClusterPrimary() string {

	section := A3Read("PF", "Cluster Primary")
	if section == nil {
		return ""
	}
	return section["Cluster Primary"]["ip"]

}


