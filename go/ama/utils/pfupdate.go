//pfupdate.go implements update pfconf element.
package utils

import (
	//"context"
	"fmt"
	"net"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	//"github.com/inverse-inc/packetfence/go/log"
)

func UpdateEmail(email string) error {
	section := a3config.Section{
		"alerting": {
			"emailaddr": email,
		},
	}
	return a3config.A3Commit("PF", section)
}

func UpdateHostname(hostname string) error {
	section := a3config.Section{
		"general": {
			"hostname": hostname,
		},
	}
	return a3config.A3Commit("PF", section)
}

func UpdateInterface(i item) error {
	keyname := fmt.Sprintf("interface %s", i.Name)
	var Type string = ""

	if i.Type != "MANAGEMENT" {
		Type = fmt.Sprintf("internal,%s", strings.ToLower(i.Services))
	} else {
		Type = fmt.Sprintf("management,%s", strings.ToLower(i.Services))
	}

	section := a3config.Section{
		keyname: {
			"ip":   i.IpAddr,
			"type": Type,
			"mask": i.NetMask,
			"vip":  i.Vip,
		},
	}
	return a3config.A3Commit("PF", section)
}
func UpdateNetconf(i item) error {
	a := netMask_Str2Len(i.NetMask)

	ipv4Addr := net.ParseIP(i.IpAddr)
	ipv4Mask := net.CIDRMask(a, 32)
	keyname := fmt.Sprintf("%s", ipv4Addr.Mask(ipv4Mask)) // ip & mask

	var Type string = ""

	if i.Type == "MANAGEMENT" {
		return nil
	} else {
		Type = fmt.Sprintf("vlan-%s,%s", strings.ToLower(i.Type), strings.ToLower(i.Services))
	}

	section := a3config.Section{
		keyname: {
			"gateway": i.IpAddr,
			"type":    Type,
			"netmask": i.NetMask,
		},
	}
	return a3config.A3Commit("NETWORKS", section)
}
