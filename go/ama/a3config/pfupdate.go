//pfupdate.go implements update pfconf element.
package a3config

import (
	//"context"
	"context"

	"fmt"
	"net"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
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
		err = UpdateEthInterface(i)
	}
	return err
}

func UpdateEthInterface(i Item) error {
	err := utils.UpdateEthIface(i.Name, i.IpAddr, i.NetMask)
	if err != nil {
		return err
	}
	keyname := fmt.Sprintf("interface %s", i.Name)

	var Type string
	if i.Services != "" {
		Type = fmt.Sprintf("%s,%s", strings.ToLower(i.Type), strings.ToLower(i.Services))
	} else {
		Type = strings.ToLower(i.Type)
	}

	if i.Vip != "" && i.Vip != "0.0.0.0" {
		Type = fmt.Sprintf("%s,high-availability", Type)
	}

	section := Section{
		keyname: {
			"ip":   i.IpAddr,
			"type": Type,
			"mask": i.NetMask,
		},
	}
	return A3Commit("PF", section)
}

func UpdateVlanInterface(i Item) error {
	s := []rune(i.Name)
	vlan := string(s[4:]) /*need to delete vlan for name*/
	ifname := fmt.Sprintf("eth0.%s", vlan)

	err := utils.UpdateVlanIface(ifname, vlan, i.IpAddr, i.NetMask)
	if err != nil {
		return err
	}
	var Type string
	keyname := fmt.Sprintf("interface %s", ifname)
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

	keyname := IpBitwiseAndMask(i.IpAddr, i.NetMask) // ip & mask
	s := strings.Split(keyname, ".")
	dhcpstart := fmt.Sprintf("%s.%s.%s.10", s[0], s[1], s[2])
	dhcpend := fmt.Sprintf("%s.%s.%s.246", s[0], s[1], s[2])

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
			"dhcp_start":              dhcpstart,
			"gateway":                 i.IpAddr,
			"domain-name":             Domain,
			"nat_enabled":             "disabled",
			"named":                   "enabled",
			"dhcp_max_lease_time":     "30",
			"fake_mac_enabled":        "disabled",
			"dhcpd":                   "enabled",
			"dhcp_end":                dhcpend,
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

func DeletePrimaryClusterconf(i Item) error {
	var sectionid string
	isvlan := VlanInface(i.Name)
	ifname := ChangeUiInterfacename(i.Name)

	if isvlan {
		sectionid = fmt.Sprintf("CLUSTER interface %s", ifname)
		A3Delete("CLUSTER", sectionid)
		sectionid = fmt.Sprintf("%s interface %s", GetHostname(), ifname)
		return A3Delete("CLUSTER", sectionid)
	} else {
		sectionid = "CLUSTER"
		A3Delete("CLUSTER", sectionid)
		sectionid = fmt.Sprintf("CLUSTER interface %s", ifname)
		A3Delete("CLUSTER", sectionid)
		sectionid = GetHostname()
		A3Delete("CLUSTER", sectionid)
		sectionid = fmt.Sprintf("%s interface %s", GetHostname(), ifname)
		return A3Delete("CLUSTER", sectionid)
	}

}

func UpdatePrimaryClusterconf(enable bool, i Item) error {
	var keyname string

	if !enable {
		/* cp cluster.conf.example to replace cluster.conf */
		utils.UseDefaultClusterConf()
		return nil
	}
	if i.Vip == "" || i.Vip == "0.0.0.0" {
		return nil
	}
	utils.CreateClusterId()
	isvlan := VlanInface(i.Name)
	if isvlan {
		name := []rune(i.Name) /*need to delete vlan for name*/
		keyname = fmt.Sprintf("CLUSTER interface eth0.%s", string(name[4:]))
		section := Section{
			keyname: {
				"ip": i.Vip,
			},
		}
		return A3Commit("CLUSTER", section)

	} else {
		section := Section{
			"CLUSTER": {
				"management_ip": i.Vip,
			},
			"CLUSTER interface eth0": {
				"ip": i.Vip,
			},
		}
		return A3Commit("CLUSTER", section)
	}
}
func UpdateJoinClusterconf(i Item, hostname string) error {
	var keyname string

	if !CheckClusterEnable() {
		log.LoggerWContext(context.Background()).Info(fmt.Sprintf(" Cluster Disenabled"))
		return nil
	}

	isvlan := VlanInface(i.Name)
	if isvlan {
		name := []rune(i.Name) /*need to delete vlan for name*/
		keyname = fmt.Sprintf("%s interface eth0.%s", hostname, string(name[4:]))

		section := Section{
			keyname: {
				"ip": i.IpAddr,
			},
		}
		return A3Commit("CLUSTER", section)

	} else {
		keyname = fmt.Sprintf("%s interface %s", hostname, i.Name)
		section := Section{
			hostname: {
				"management_ip": i.IpAddr,
			},
			keyname: {
				"ip": i.IpAddr,
			},
		}
		return A3Commit("CLUSTER", section)
	}
}

func UpdateWebservicesAcct() error {
	rsection := A3ReadFull("PF", "webservices")

	wsection := Section{
		"webservices": {
			"user": rsection["webservices"]["user"],
			"pass": rsection["webservices"]["pass"],
		},
	}

	return A3Commit("PF", wsection)
}

func UpdateGaleraUser() error {

	rsection := A3ReadFull("PF", "database")

	wsection := Section{
		"active_active": {
			"galera_replication_username": rsection["database"]["user"],
			"galera_replication_password": rsection["database"]["pass"],
		},
	}

	return A3Commit("PF", wsection)

}

func WriteUserPassToPF(host, username, passw string) error {

	section := Section{
		"Cluster Primary": {
			"ip": host,
		},
		"webservices": {
			"user": username,
			"pass": passw,
		},
	}
	return A3Commit("PF", section)

}

func UpdateWebservices(user, password string) error {

	section := Section{
		"webservices": {
			"user": user,
			"pass": password,
		},
	}
	return A3Commit("PF", section)

}
