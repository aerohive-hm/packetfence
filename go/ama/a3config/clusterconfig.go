// GET/POST /a3/api/v1/configuration/cluster
// POST /a3/api/v1/configuration/cluster/remove

package a3config

import (
	"context"
	"fmt"
	"regexp"

	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

// 1. fetch the status of all members in cluster
// 2. change settings about some cluster options

// cluster node information

type NodeInfo struct {
	IpAddr   string
	Hostname string
}

type ClusterNodeItem struct {
	Hostname string `json:"hostname"`
	IpAddr   string `json:"ipaddr"`
	NodeType string `json:"type"`
	Status   string `json:"status"`
}

type ClusterInfoData struct {
	RouterId  string            `json:"vrid"` //virtual router ID
	SharedKey string            `json:"sharedkey"`
	Ifaces    map[string]string `json:"interfaces,omitempty"`
	Nodes     []ClusterNodeItem `json:"nodes,omitempty"`
}

// Remove Node from cluster
type ClusterRemoveData struct {
	Hostname []string `json:"hostname"`
}

func ClusterNew() Section {
	return A3Read("CLUSTER", "all")
}

func (sections Section) GetPrimaryClusterVip(ifname string) string {
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

func (sections Section) CheckClusterEnable() bool {
	if sections == nil {
		return false
	}
	if sections["CLUSTER"]["management_ip"] != "" {
		return true
	}
	return false
}

func (sections Section) GetClusterVips() map[string]string {
	if sections == nil {
		return map[string]string{}
	}

	vips := make(map[string]string)
	r := regexp.MustCompile(`CLUSTER\s*interface\s*([\w\.]+)`)
	for k, v := range sections {
		ret := r.FindStringSubmatch(k)
		if len(ret) < 2 {
			continue
		}
		vips[ret[1]] = v["ip"]
	}

	return vips
}

func (sections Section) FetchNodesInfo() []NodeInfo {
	if sections == nil {
		return nil
	}

	nodes := []NodeInfo{}
	for secName, kvpair := range sections {
		if secName == "CLUSTER" {
			continue
		}

		for k, v := range kvpair {
			if k == "management_ip" {
				node := NodeInfo{IpAddr: v, Hostname: secName}
				nodes = append(nodes, node)
			}
		}
	}
	return nodes
}

func DeletePrimaryClusterconf(i Item) error {
	isvlan := VlanInface(i.Name)
	ifname := ChangeUiIfname(i.Name, i.Prefix)
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
		keyname = fmt.Sprintf("CLUSTER interface %s.%s", i.Prefix, string(name[4:]))
		section := Section{
			keyname: {
				"ip": i.Vip,
			},
		}
		return A3Commit("CLUSTER", section)

	} else {
		sectionid := fmt.Sprintf("CLUSTER interface %s", i.Prefix)
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

	if !ClusterNew().CheckClusterEnable() {
		log.LoggerWContext(context.Background()).Info(fmt.Sprintf(" Cluster Disenabled"))
		return nil
	}

	isvlan := VlanInface(i.Name)
	if isvlan {
		name := []rune(i.Name) /*need to delete vlan for name*/
		keyname = fmt.Sprintf("%s interface %s.%s", hostname, i.Prefix, string(name[4:]))

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

func UpdateClusterFile() {
	cmd := `echo -e "\n/usr/local/pf/conf/cloud.conf\n` +
		`/usr/local/pf/conf/clusterid.conf\n` +
		`/usr/local/pf/conf/dbinfo.A3" >> /usr/local/pf/conf/cluster-files.txt`
	utils.ExecShell(cmd)
}
