package a3config

import (
	"context"
	"fmt"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/utils"
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

func GetNetworksData(ctx context.Context) NetworksData {
	var context context.Context
	networksData := NetworksData{}

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}
	networksData.Items = GetItemsValue(context)
	networksData.ClusterEnable = "true"
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

func GetItemsValue(ctx context.Context) []item {
	var items []item
	ifaces, errint := utils.GetIfaceList("all")
	if errint < 0 {
		fmt.Errorf("Get interfaces infomation failed.")
		return items
	}
	for _, iface := range ifaces {
		item := new(item)
		//      if iface.Master == "" {
		//          item.Name = iface.Name
		//      } else {
		//          item.Name = iface.Master
		//      }
		item.Name = iface.Name
		item.Id = "interface"
		item.IpAddr = iface.IpAddr
		item.NetMask = GetIfaceElementVlaue(iface.Name, "mask")
		item.Vip = GetIfaceElementVlaue(iface.Name, "vip")
		item.Type = strings.ToUpper(GetIfaceType(iface.Name))
		item.Services = strings.ToUpper(strings.Join(GetIfaceServices(iface.Name), ","))
		items = append(items, *item)
	}
	return items

}

func UpdateItemsValue(ctx context.Context, items []item) error {
	var err error
	for _, item := range items {
		err = UpdateInterface(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateInterface error:" + err.Error())
			fmt.Println("UpdateInterface err")
			return err
		}
		err = UpdateNetconf(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
			fmt.Println("UpdateNetconf err")
			return err
		}
	}
	return nil

}

func UpdateNetworksData(ctx context.Context, networksData NetworksData) error {
	var context context.Context

	if ctx == nil {
		context = contextNetworks
	} else {
		context = ctx
	}

	err := UpdateHostname(networksData.HostName)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}
	err = UpdateItemsValue(context, networksData.Items)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateItemsValue error:" + err.Error())
		return err
	}
	return err
}
