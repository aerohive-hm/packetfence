//pfget.go implements get pfconf element data.
package a3config

import (
//"context"
//"fmt"
//"strings"
//"github.com/inverse-inc/packetfence/go/ama/a3config"
//"github.com/inverse-inc/packetfence/go/log"
)

func GetPfHostname() string {
	section := A3Read("PF", "general")
	if section == nil {
		return ""
	}
	return section["general"]["hostname"]
}

func GetWebServices() Section {
	return A3ReadFull("PF", "webservices")
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
func GetPrimaryHostname() string {

	section := A3Read("PF", "Cluster Primary")
	if section == nil {
		return ""
	}
	return section["Cluster Primary"]["hostname"]

}

func GetDbRootPassword() string {

	section := A3Read("A3DB", "")
	if section == nil {
		return ""
	}
	return section[""]["dbroot_pass"]
}
