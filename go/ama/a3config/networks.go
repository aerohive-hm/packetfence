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
	Original string `json:"original"`
	Name     string `json:"name"`
	Prefix   string `json:"prefix,omitempty"`
	IpAddr   string `json:"ip_addr"`
	NetMask  string `json:"netmask"`
	Vip      string `json:"vip"`
	Type     string `json:"type"`
	Services string `json:"services"`
}

type NetworksData struct {
	ClusterEnable bool   `json:"cluster_enable"`
	HostName      string `json:"hostname,omitempty"`
	Items         []Item `json:"items,omitempty"`
}

var contextNetworks = log.LoggerNewContext(context.Background())
var clusterEnableDefault = true
var Isclusterjoin = false

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
		item.Prefix = iname[0]
		if len(iname) > 1 {
			item.Name = fmt.Sprintf("VLAN%s", iname[1])
		} else {
			item.Name = iname[0]
		}
		item.Original = item.Name
		value, _ := strconv.Atoi(iface.NetMask)
		item.IpAddr = iface.IpAddr
		item.NetMask = utils.NetmaskLen2Str(value)
		item.Vip = ClusterNew().GetPrimaryClusterVip(iface.Name)
		item.Type = GetIfaceType(iface.Name)
		item.Services = strings.Join(GetIfaceServices(iface.Name), ",")
		items = append(items, *item)
	}
	return items
}

func UpdateItemsValue(ctx context.Context, enable bool, items []Item) error {

	err := DeleteIfcfgFile(ctx)
	if err != nil {
		log.LoggerWContext(ctx).Error("DeleteIfcfgFile error:" + err.Error())
		return err
	}
	for _, item := range items {
		err = UpdateInterface(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update Interface error:" + err.Error())
			return err
		}
		err = UpdateNetconf(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update Netconf error:" + err.Error())
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
		err = UpdateJoinClusterconf(item, GetPfHostname())
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
	networksData.ClusterEnable = clusterEnableDefault
	networksData.HostName = GetPfHostname()
	return networksData
}

func UpdateNetworksData(ctx context.Context, networksData NetworksData) error {
	var context context.Context

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}
	clusterEnableDefault = networksData.ClusterEnable
	Isclusterjoin = false
	if len(networksData.Items) == 0 {
		/*only update cluster enable*/
		return nil
	}
	err := CheckItemValid(ctx, networksData.ClusterEnable, networksData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error("CheckItemValid error:" + err.Error())
		return err
	}
	err = UpdateHostname(networksData.HostName)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}
	err = UpdateItemsValue(context, networksData.ClusterEnable, networksData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateItemsValue error:" + err.Error())
		return err
	}
	return err
}

func CheckItemIpValid(ctx context.Context, enable bool, items []Item) error {
	msg := ""
	eip := make(map[string]string)
	/*ip and vip should be the same net range*/
	for _, item := range items {
		if enable && !utils.IsSameIpRange(item.IpAddr, item.Vip, item.NetMask) {
			msg = fmt.Sprintf("ip(%s) and vip(%s) should be the same net range", item.IpAddr, item.Vip)
			return errors.New(msg)
		}

		if !VlanInface(item.Name) {
			eip[item.Name] = item.IpAddr
		}
		/*mask should be valid*/
		err := CheckMaskValid(item.NetMask)
		if err != nil {
			return err
		}
	}

	/*eth ip and vlan ip should not be the same net range*/
	for k1, item := range items {
		if !VlanInface(item.Name) {
			continue
		}

		if utils.IsSameIpRange(item.IpAddr, eip[item.Prefix], item.NetMask) {
			msg = fmt.Sprintf("%s ip(%s) and %s (%s) should not be the same net range", item.Prefix, eip[item.Prefix], item.Name, item.IpAddr)
			return errors.New(msg)
		}
		/* vlan ip should not be the same*/
		for k2, i := range items {
			if !VlanInface(i.Name) || k1 == k2 || item.Prefix != i.Prefix {
				continue
			}

			if item.IpAddr == i.IpAddr {
				msg = fmt.Sprintf("ip(%s) is more than one in form", item.IpAddr)
				return errors.New(msg)
			}
			/* vlan name should not be the same*/
			if item.Name == i.Name {
				msg = fmt.Sprintf("vlan name(%s) is more than one in form", item.Name)
				return errors.New(msg)
			}
			/* vlan vip should not be the same*/
			if enable && item.Vip == i.Vip {
				msg = fmt.Sprintf("vlan vip(%s) is more than one in form", item.Vip)
				return errors.New(msg)
			}
		}
	}
	return nil
}

func GetPrefixIP(i Item) string {
	ifname := strings.ToLower(i.Prefix)
	ip, _ := utils.GetifaceIpInfo(ifname)
	return ip
}
func CheckItemTypeValid(ctx context.Context, items []Item) error {
	msg := ""
	for _, i := range items {
		/*eth0 must contain management, other can not contian management*/
		if i.Name == "eth0" {
			if i.Type != "MANAGEMENT" {
				msg = fmt.Sprintf("the interface eth0  must be management type")
				return errors.New(msg)
			}
		} else {
			/*vlan can not allowed to contain management*/
			if i.Type == "MANAGEMENT" {
				msg = fmt.Sprintf("the %s does not allow to contain management type", i.Name)
				return errors.New(msg)
			}
			/*if vlan type is portal ,the service must contian portal*/
			if i.Type == "PORTAL" {
				if !strings.Contains(i.Services, "PORTAL") {
					msg = fmt.Sprintf("the %s must contain portal service if the type is portal", i.Name)
					return errors.New(msg)
				}
			}
		}
	}
	return nil
}

func CheckItemServiceValid(ctx context.Context, items []Item) error {
	msg := ""
	for _, item := range items {
		if strings.Contains(item.Type, "PORTAL") {
			if item.Services == "" {
				msg = fmt.Sprintf("%s type is Portal, service portal is mandatory", item.Name)
				return errors.New(msg)
			}
		}
	}
	return nil
}
func CheckMaskValid(mask string) error {

	var i, value int = 0, 0

	msg := fmt.Sprintf("mask(%s) is invalid", mask)

	if mask == "0.0.0.0" {
		return errors.New(msg)
	}

	sections := strings.Split(mask, ".")
	l := len(sections)
	if l != 4 {
		return errors.New(msg)
	}

	for k := 0; k < l; k++ {
		i = 0
		value, _ = strconv.Atoi(sections[k])

		for (value & 128) != 0 {
			i++
			value = value << 1
		}
		if i >= 0 && i < 8 && (value&255) != 0 {
			return errors.New(msg)
		}
	}
	return nil
}

func IsBroadcastIp(ip, mask string) bool {
	netip := utils.IpBitwiseAndMask(ip, mask)
	snetip := strings.Split(netip, ".")
	smask := strings.Split(mask, ".")
	s := make([]string, 4)
	for k := 0; k < 4; k++ {
		value, _ := strconv.Atoi(snetip[k])
		mvalue, _ := strconv.Atoi(smask[k])
		b := (uint(^mvalue) | uint(value)) & 255
		s[k] = strconv.Itoa(int(b))
	}
	boradip := strings.Join(s, ".")
	if ip == boradip {
		return true
	}
	return false
}

func CheckItemValid(ctx context.Context, enable bool, items []Item) error {
	err := CheckItemIpValid(ctx, enable, items)
	if err != nil {
		return err
	}
	err = CheckItemTypeValid(ctx, items)
	if err != nil {
		return err
	}
	err = CheckItemServiceValid(ctx, items)
	if err != nil {
		return err
	}
	return nil
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
	ifname := ChangeUiIfname(item.Name, item.Prefix)
	ip := item.IpAddr
	netmask := item.NetMask
	var section Section
	var sysGatewayCfgFile string
	var dns []string
	var i int
	var l string

	log.LoggerWContext(ctx).Info(fmt.Sprintf("writeOneNetworkConfig: ifname=%s, "+
		"ip =%s, netmask =%s", ifname, ip, netmask))

	// ifcfgfile: /usr/local/pf/var/ifcfg-
	ifcfgFile := varDir + interfaceConfFile + ifname
	// sysifCfgFile: /etc/sysconfig/network-scripts
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

	section[""]["ONBOOT"] = "yes"
	section[""]["BOOTPROTO"] = "static"
	section[""]["NM_CONTROLLED"] = "no"
	section[""]["IPADDR"] = ip
	section[""]["NETMASK"] = netmask

	err := A3CommitPath(ifcfgFile, section)

	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error: " + err.Error() + ifcfgFile)
		return err
	}

	if !utils.IsVlanIface(ifname) {
		/* write dns to sysifcfgfile for eth0*/
		dns = utils.GetDnsServer()
		for i, l = range dns {
			section[""]["DNS"+strconv.Itoa(i+1)] = l
		}
	}
	err = A3CommitPath(sysifCfgFile, section)
	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error: " + err.Error() +
			sysifCfgFile)
	}
	//write gateway to etc/sysconfig/network
	section = Section{
		"": {
			"GATEWAY": utils.GetA3DefaultGW(),
		},
	}

	sysGatewayCfgFile = networtConfDir + networkConfFile

	err = A3CommitPath(sysGatewayCfgFile, section)
	if err != nil {
		log.LoggerWContext(ctx).Error("SetNetworkInterface error: " + err.Error() +
			sysGatewayCfgFile)
		return err
	}
	return nil
}

func DeleteIfcfgFile(ctx context.Context) error {
	err := utils.DeleteFile("/usr/local/pf/var/ifcfg-eth*")
	if err != nil {
		log.LoggerWContext(ctx).Error("DeleteIfcfgFile  error")
		return err
	}
	err = utils.DeleteFile("/etc/sysconfig/network-scripts/ifcfg-eth*")
	if err != nil {
		log.LoggerWContext(ctx).Error("DeleteIfcfgFile error")
		return err
	}
	return nil
}
