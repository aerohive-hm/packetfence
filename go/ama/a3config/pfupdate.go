//pfupdate.go implements update pfconf element.
package a3config

import (
	//"context"
	"fmt"
	"net"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/utils"
	//"github.com/inverse-inc/packetfence/go/log"
)

func UpdateEmail(email string) error {
	section := Section{
		"alerting": {
			"emailaddr": email,
		},
	}
	return A3Commit("PF", section)
}

func UpdateHostname(hostname string) error {
	section := Section{
		"general": {
			"hostname": hostname,
		},
	}
	return A3Commit("PF", section)
}

func UpdateInterface(i Item) error {
	var err error

	isvlan := VlanInface(i.Name)
	if isvlan {
		err = UpdateVlanInterface(i)
	} else {
		err = UpdateManageInterface(i)
	}
	return err
}

func UpdateManageInterface(i Item) error {
	keyname := fmt.Sprintf("interface %s", i.Name)

	var Type string
	if i.Services != "" {
		Type = fmt.Sprintf("management,%s", strings.ToLower(i.Services))
	} else {
		Type = "management"
	}

	if i.Vip == "" {
		i.Vip = "0.0.0.0"
	}
	section := Section{
		keyname: {
			"ip":   i.IpAddr,
			"type": Type,
			"mask": i.NetMask,
			"vip":  i.Vip,
		},
	}
	return A3Commit("PF", section)
}

func UpdateVlanInterface(i Item) error {
	name := []rune(i.Name) /*need to delete vlan for name*/
	keyname := fmt.Sprintf("interface eth0.%s", string(name[4:]))

	var Type string
	if i.Services != "" {
		Type = fmt.Sprintf("internal,%s", strings.ToLower(i.Services))
	} else {
		Type = "internal"
	}

	section := Section{
		keyname: {
			"ip":          i.IpAddr,
			"type":        Type,
			"mask":        i.NetMask,
			"enforcement": "vlan",
		},
	}
	return A3Commit("PF", section)
}
func UpdateNetconf(i Item) error {
	var Type string = ""

	isvlan := VlanInface(i.Name)
	if !isvlan {
		return nil
	}

	a := utils.NetmaskStr2Len(i.NetMask)
	ipv4Addr := net.ParseIP(i.IpAddr)
	ipv4Mask := net.CIDRMask(a, 32)
	keyname := fmt.Sprintf("%s", ipv4Addr.Mask(ipv4Mask)) // ip & mask

	if i.Services != "" {
		Type = fmt.Sprintf("vlan-%s,%s", strings.ToLower(i.Type), strings.ToLower(i.Services))
	} else {
		Type = fmt.Sprintf("vlan-%s", strings.ToLower(i.Type))
	}
	Domain := fmt.Sprintf("%s.%s", Type, GetDomain())
	section := Section{
		keyname: {
			"dns":                     i.IpAddr,
			"split_network":           "disabled",
			"dhcp_start":              i.IpAddr,
			"gateway":                 i.IpAddr,
			"domain-name":             Domain,
			"nat_enabled":             "disabled",
			"named":                   "enabled",
			"dhcp_max_lease_time":     "30",
			"fake_mac_enabled":        "disabled",
			"dhcpd":                   "enabled",
			"dhcp_end":                "",
			"type":                    Type,
			"netmask":                 i.NetMask,
			"dhcp_default_lease_time": "30",
		},
	}
	return A3Commit("NETWORKS", section)
}
func DeleteNetconf(i Item) error {

	isvlan := VlanInface(i.Name)
	if !isvlan {
		return nil
	}

	a := utils.NetmaskStr2Len(i.NetMask)
	ipv4Addr := net.ParseIP(i.IpAddr)
	ipv4Mask := net.CIDRMask(a, 32)
	sectionid := fmt.Sprintf("%s", ipv4Addr.Mask(ipv4Mask)) // ip & mask

	return A3Delete("NETWORKS", sectionid)
}
