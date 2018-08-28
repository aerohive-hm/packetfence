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
	isvlan := VlanInface(ifname)
	if isvlan {
		name := []rune(ifname) /*need to delete vlan for name*/
		keyname = fmt.Sprintf("CLUSTER interface eth0.%s", string(name[4:]))
		section := A3Read("CLUSTER", keyname)
		if section == nil {
			return ""
		}
		vip = section[keyname]["ip"]

		if vip == "" {
			vip = "0.0.0.0"
		}
		return vip
	} else {
		keyname = "CLUSTER"
		section := A3Read("CLUSTER", keyname)
		if section == nil {
			return ""
		}
		vip = section["CLUSTER"]["management_ip"]
		if vip == "" {
			vip = "0.0.0.0"
		}
		return vip
	}
}

func GetKeyFromSection(sectionId string, key string) string {
	section := A3ReadFull("PF", sectionId)
	if section == nil {
		return ""
	}
	return section[sectionId][key]
}
