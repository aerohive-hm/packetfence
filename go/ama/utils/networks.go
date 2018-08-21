//networks.go implements fetching networks info.
package utils

import (
	"context"
	"fmt"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/a3conf"
	"github.com/inverse-inc/packetfence/go/log"
)

type item struct {
	Id       string `json:"id"`
	Name     string `json:"name"`
	IpAddr   string `json:"ip_addr"`
	NetMask  string `json:"netmask"`
	Vip      string `json:"vip"`
	Type     string `json:"type"`
	Services string `json:"services"`
}

type ClusterNetworksData struct {
	HostName string `json:"hostname"`
	Items    []item `json:"items"`
}

type NetworksData struct {
	ClusterEnable string `json:"cluster_enable"`
	HostName      string `json:"hostname"`
	Items         []item `json:"items"`
}

var contextNetworks = log.LoggerNewContext(context.Background())

func GetItemsValue(ctx context.Context) []item {
	var items []item
	var Services []string
	ifaces, errint := GetIfaceList("all")
	if errint < 0 {
		fmt.Errorf("Get interfaces infomation failed.")
		return items
	}
	for _, iface := range ifaces {
		item := new(item)
		if iface.Master == "" {
			item.Name = iface.Name
		} else {
			item.Name = iface.Master
		}
		item.Id = "interface"
		item.IpAddr = iface.IpAddr
		item.NetMask = iface.NetMask
		item.Vip = iface.Vip
		item.Type = GetIfaceType(iface.Name)
		Services = GetIfaceServices(iface.Name)
		item.Services = strings.Join(Services, ",")
		items = append(items, *item)
	}
	return items

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
	networksData.ClusterEnable = "todo"
	networksData.HostName = a3config.GetHostname()
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
	clusterNetworksData.HostName = a3config.GetHostname()
	return clusterNetworksData
}
