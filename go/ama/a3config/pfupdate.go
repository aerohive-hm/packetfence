//pfupdate.go implements update pfconf element.
package a3config

import (
	//"context"
	"context"
	"errors"
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
	err := utils.SetHostname(hostname)
	if err != nil {
		return err
	}
	section := Section{
		"general": {
			"hostname": hostname,
		},
	}
	return A3Commit("PF", section)
}

func UpdateInterface(i Item) error {
	/*check mask is valid*/
	err := CheckMaskValid(i.NetMask)
	if err != nil {
		return err
	}
	/*check ip vip the same net range*/
	if clusterEnableDefault {
		/*check ip vip the same net range*/
		if !utils.IsSameIpRange(i.IpAddr, i.Vip, i.NetMask) {
			msg := fmt.Sprintf("ip(%s) and vip(%s) should be the same net range", i.IpAddr, i.Vip)
			return errors.New(msg)
		}
		/*check vip if exsit*/
		ifname := ChangeUiInterfacename(i.Name, strings.ToLower(i.Prefix))
		vip := GetPrimaryClusterVip(ifname)
		if vip != i.Vip {
			if utils.IsIpExists(i.Vip) {
				msg := fmt.Sprintf("%s is exsit in net", i.Vip)
				return errors.New(msg)
			}
		}
	}

	isvlan := VlanInface(i.Name)
	if isvlan {
		err = UpdateVlanInterface(i)
	} else {
		err = UpdateEthInterface(i)
	}
	return err
}

func UpdateEthInterface(i Item) error {
	/*check eth0 ip should be equal to primary ip*/
	if i.IpAddr == ReadClusterPrimary() {
		msg := fmt.Sprintf("%s ip(%s) is equal to primary ip (%s) ", i.Prefix, i.IpAddr, ReadClusterPrimary())
		return errors.New(msg)
	}
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
	prefix := strings.ToLower(i.Prefix)
	ifname := fmt.Sprintf("%s.%s", prefix, vlan)

	err := utils.UpdateVlanIface(ifname, prefix, vlan, i.IpAddr, i.NetMask)
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

	keyname := utils.IpBitwiseAndMask(i.IpAddr, i.NetMask) // ip & mask
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
	sectionid := []string{fmt.Sprintf("%s", ipv4Addr.Mask(ipv4Mask))} // ip & mask
	return A3Delete("NETWORKS", sectionid)
}

func DeletePrimaryClusterconf(i Item) error {
	isvlan := VlanInface(i.Name)
	ifname := ChangeUiInterfacename(i.Name, strings.ToLower(i.Prefix))
	hostname := GetPfHostname()
	if isvlan {
		sectionid := []string{
			fmt.Sprintf("CLUSTER interface %s", ifname),
			fmt.Sprintf("%s interface %s", hostname, ifname),
		}
		return A3Delete("CLUSTER", sectionid)
	} else {
		sectionid := []string{
			"CLUSTER",
			fmt.Sprintf("CLUSTER interface %s", ifname),
			hostname,
			fmt.Sprintf("%s interface %s", hostname, ifname),
		}
		return A3Delete("CLUSTER", sectionid)
	}

}

func matchHost(sectionId string, hostname []string) bool {
	for _, host := range hostname {
		l := len(host)
		if sectionId[:l] == host {
			return true
		}
	}
	return false
}

// remove a server from cluster.conf
func RemoveClusterServer(hostname []string) {
	sections := A3Read("CLUSTER", "all")
	var ids []string
	for key, _ := range sections {
		if matchHost(key, hostname) {
			ids = append(ids, key)
		}
	}

	if len(ids) > 0 {
		log.LoggerWContext(context.Background()).Info("update cluster.conf")
		A3Delete("CLUSTER", ids)
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
		keyname = fmt.Sprintf("CLUSTER interface %s.%s", strings.ToLower(i.Prefix), string(name[4:]))
		section := Section{
			keyname: {
				"ip": i.Vip,
			},
		}
		return A3Commit("CLUSTER", section)

	} else {
		sectionid := fmt.Sprintf("CLUSTER interface %s", strings.ToLower(i.Prefix))
		section := Section{
			"CLUSTER": {
				"management_ip": i.Vip,
			},
			sectionid: {
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
		keyname = fmt.Sprintf("%s interface %s.%s", hostname, strings.ToLower(i.Prefix), string(name[4:]))

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

	rsection := A3ReadFull("PF", "active_active")["active_active"]

	wsection := Section{
		"active_active": {
			"galera_replication_username": rsection["galera_replication_username"],
			"galera_replication_password": rsection["galera_replication_password"],
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
func UpdatePrimaryHostnameToClusterPF(hostname string) error {

	section := Section{
		"Cluster Primary": {
			"hostname": hostname,
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

func UpdateClusterFile() {
	cmd := `echo -e "\n/usr/local/pf/conf/cloud.conf\n` +
		`/usr/local/pf/conf/clusterid.conf" >> /usr/local/pf/conf/cluster-files.txt`
	utils.ExecShell(cmd)
}
