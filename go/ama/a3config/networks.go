//networks.go implements fetching networks info.
package a3config

import (
	"context"
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

type ClusterNetworksData struct {
	HostName string `json:"hostname"`
	Items    []Item `json:"items"`
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
		item.Type = strings.ToUpper(GetIfaceType(iface.Name))
		item.Services = strings.ToUpper(strings.Join(GetIfaceServices(iface.Name), ","))
		items = append(items, *item)
	}
	return items

}

func UpdateItemsValue(ctx context.Context, items []Item) error {
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

		err = UpdatePrimaryClusterconf(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdatePrimaryClusterconf error:" + err.Error())
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

func GetClusterNetworksData(ctx context.Context) ClusterNetworksData {
	var context context.Context
	clusterNetworksData := ClusterNetworksData{}

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}
	clusterNetworksData.Items = GetItemsValue(context)
	clusterNetworksData.HostName = GetHostname()
	return clusterNetworksData
}

func UpdateNetworksData(ctx context.Context, networksData NetworksData) error {
	var context context.Context

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}
	//TODO Write networksData.ClusterEnable
	err := UpdateHostname(networksData.HostName)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}
	utils.SetHostname(networksData.HostName)
	err = UpdateItemsValue(context, networksData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateItemsValue error:" + err.Error())
		return err
	}
	return err
}
func UpdateClusterNetworksData(ctx context.Context, clusterNetworksData ClusterNetworksData) error {
	var context context.Context

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}

	err := UpdateHostname(clusterNetworksData.HostName)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}
	err = UpdateItemsValue(context, clusterNetworksData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateItemsValue error:" + err.Error())
		return err
	}
	return err
}
