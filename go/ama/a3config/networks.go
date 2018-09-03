//networks.go implements fetching networks info.
package a3config

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type Item struct {
	Name     string `json:"name"`
	IpAddr   string `json:"ip_addr"`
	NetMask  string `json:"netmask"`
	Vip      string `json:"vip"`
	Type     string `json:"type"`
	Services string `json:"services"`
}

type NetworksData struct {
	ClusterEnable bool   `json:"cluster_enable"`
	HostName      string `json:"hostname"`
	Items         []Item `json:"items"`
}

var contextNetworks = log.LoggerNewContext(context.Background())

func GetItemsValue(ctx context.Context) []Item {
	var items []Item
	ifaces, errint := utils.GetIfaceList("all")
	if errint < 0 {
		fmt.Errorf("Get interfaces infomation failed.")
		return items
	}
	for _, iface := range ifaces {
		item := new(Item)
		iname := strings.Split(iface.Name, ".")
		if len(iname) > 1 {
			item.Name = fmt.Sprintf("VLAN%s", iname[1])
		} else {
			item.Name = iname[0]
		}
		value, _ := strconv.Atoi(iface.NetMask)
		item.IpAddr = iface.IpAddr
		item.NetMask = utils.NetmaskLen2Str(value)
		item.Vip = GetPrimaryClusterVip(iface.Name)
		item.Type = GetIfaceType(iface.Name)
		item.Services = strings.Join(GetIfaceServices(iface.Name), ",")
		items = append(items, *item)
	}
	return items

}

func UpdateItemsValue(ctx context.Context, enable bool, items []Item) error {
	var err error

	for _, item := range items {
		err = UpdateInterface(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateInterface error:" + err.Error())
			return err
		}
		err = UpdateNetconf(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
			return err
		}
		err = writeOneNetworkConfig(ctx, item)
		if err != nil {
			log.LoggerWContext(ctx).Error("writeOneNetworkConfig error:" + err.Error())
			return err
		}
		err = UpdatePrimaryClusterconf(enable, item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdatePrimaryClusterconf error:" + err.Error())
			return err
		}
	}

	for _, item := range items {
		err = UpdateJoinClusterconf(item, GetHostname())
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateJoinClusterconf error:" + err.Error())
			return err
		}
	}

	return nil

}

func GetNetworksData(ctx context.Context) NetworksData {
	var context context.Context
	networksData := NetworksData{}

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}
	networksData.Items = GetItemsValue(context)
	networksData.ClusterEnable = true
	networksData.HostName = GetHostname()
	return networksData
}

func UpdateNetworksData(ctx context.Context, networksData NetworksData) error {
	var context context.Context

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}
	//first check if contines management type
	if !IsContainManageType(ctx, networksData.Items) {
		err := errors.New("the interface does not contain management type ")
		log.LoggerWContext(ctx).Error("UpdateNetworksData error:" + err.Error())
		return err
	}
	err := UpdateHostname(networksData.HostName)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}
	utils.SetHostname(networksData.HostName)
	err = UpdateItemsValue(context, networksData.ClusterEnable, networksData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateItemsValue error:" + err.Error())
		return err
	}
	return err
}
func IsContainManageType(ctx context.Context, items []Item) bool {
	for _, item := range items {
		if strings.Contains(item.Type, "MANAGEMENT") {
			return true
		}
	}
	return false
}

const (
	networtConfDir    = "/etc/sysconfig/"
	interfaceConfDir  = "network-scripts/"
	networkConfFile   = "network"
	interfaceConfFile = "ifcfg-"
	varDir            = "/usr/local/pf/var/"
)

// Write one network interface into system files
// create ifcfg-xxx file and write IpAddr, Netmask
// write gateway to system files
func writeOneNetworkConfig(ctx context.Context, item Item) error {
	ifname := ChangeUiInterfacename(item.Name)
	ip := item.IpAddr
	netmask := item.NetMask
	log.LoggerWContext(ctx).Info(fmt.Sprintf("writeOneNetworkConfig:ifname=%s ,ip =%s, netmask =%s", ifname, ip, netmask))

	var section Section
	// write to /usr/local/pf/var/ifcfg- firstly
	ifcfgFile := varDir + interfaceConfFile + ifname
	// write to /etc/sysconfig/network-scripts/ifcfg-
	sysifCfgFile := networtConfDir + interfaceConfDir + interfaceConfFile + ifname

	//eth0, eth0.xx
	if utils.IsVlanIface(ifname) {
		section = Section{
			"": {
				"DEVICE": ifname,
				"VLAN":   "yes",
			},
		}
	} else {
		section = Section{
			"": {
				"DEVICE": ifname,
				"HWADDR": "",
			},
		}
	}
	err := A3CommitPath(ifcfgFile, section)

	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error:" + err.Error() + ifcfgFile)
		return err
	}
	err = A3CommitPath(sysifCfgFile, section)
	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error:" + err.Error() + sysifCfgFile)
		return err
	}
	section = Section{
		"": {
			"ONBOOT":        "yes",
			"BOOTPROTO":     "static",
			"NM_CONTROLLED": "no",
			"IPADDR":        ip,
			"NETMASK":       netmask,
		},
	}
	err = A3CommitPath(ifcfgFile, section)

	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error:" + err.Error() + ifcfgFile)
		return err
	}
	//just write another copy to /etc/sysconfig/

	err = A3CommitPath(sysifCfgFile, section)
	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error:" + err.Error() + sysifCfgFile)
		return err
	}

	// don't need write gateway
	if utils.IsVlanIface(ifname) {
		return nil
	}

	//write gateway
	section = Section{
		"": {
			"GATEWAY": utils.GetA3DefaultGW(),
		},
	}

	sysGatewayCfgFile := networtConfDir + networkConfFile

	err = A3CommitPath(sysGatewayCfgFile, section)
	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error:" + err.Error() + sysGatewayCfgFile)
		return err
	}

	return nil
}

// Set network interface into system files
// Only handle CentOS /usr/local/pf/html/pfappserver/root/interface/interface_rhel.tt
func WriteNetworkConfigs(ctx context.Context, networksData NetworksData) error {

	for _, item := range networksData.Items {
		err := writeOneNetworkConfig(ctx, item)
		if err != nil {
			log.LoggerWContext(ctx).Error("writeOneNetworkConfig error:" + err.Error())
			return err
		}
	}

	return nil
}
