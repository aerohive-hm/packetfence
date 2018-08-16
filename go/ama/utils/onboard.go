//onboard.go implements fetching onboarding info.
package utils

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/fetch"
	"github.com/inverse-inc/packetfence/go/log"
)

type A3Interface struct {
	Parent      string   `json:"Parent"`
	Vlan        string   `json:"vlan"`
	IpAddress   string   `json:"ipaddress"`
	Vip         string   `json:"vip"`
	Netmask     string   `json:"netmask"`
	Type        string   `json:"type"`
	Service     []string `json:"service"`
	Description string   `json:"description"`
}

type A3OnboardingData struct {
	Msgtype         string        `json:"msgtype"`
	MacAddress      string        `json:"macAddress"`
	IpMode          string        `json:"ipMode"`
	IpAddress       string        `json:"ipaddress"`
	Netmask         string        `json:"netmask"`
	DefaultGateway  string        `json:"defaultGateway"`
	SoftwareVersion string        `json:"softwareVersion"`
	SystemUptime    uint64        `json:"systemUpTime"`
	Vip             string        `json:"vip"`
	ClusterHostName string        `json:"clusterHostName"`
	ClusterPrimary  bool          `json:"clusterPrimary"`
	Interfaces      []A3Interface `json:"interfaces"`
}

type A3OnboardingHeader struct {
	SystemID   string `json:"systemId"`
	ClusterID  string `json:"clusterId"`
	Hostname   string `json:"hostname"`
	SequenceID string `json:"sequenceId"`
}

type A3OnboardingInfo struct {
	Header A3OnboardingHeader `json:"header"`
	Data   A3OnboardingData   `json:"data"`
}

func (onboardingData *A3OnboardingData) GetValue(ctx context.Context) {
	ifaces, errint := GetIfaceList("all")
	if errint < 0 {
		fmt.Errorf("Get interfaces infomation failed.")
		return
	}
	for _, iface := range ifaces {
		a3Interface := new(A3Interface)
		if iface.Master == "" {
			a3Interface.Parent = iface.Name
		} else {
			a3Interface.Parent = iface.Master
		}
		a3Interface.Vlan = iface.Vlan
		a3Interface.IpAddress = iface.IpAddr
		a3Interface.Netmask = iface.NetMask
		a3Interface.Vip = iface.Vip
		//a3Interface.Type = "Todo"
		//a3Interface.Service = "Todo"
		a3Interface.Description = iface.Name + " VLAN " + iface.Vlan
		onboardingData.Interfaces = append(onboardingData.Interfaces, *a3Interface)
	}

	onboardingData.Msgtype = "connect"
	//onboardingData.IpMode = "Todo"
	//onboardingData.DefaultGateway = "Todo"
	//onboardingData.SoftwareVersion = "Todo"
	//onboardingData.SystemUptime = Todo
	//onboardingData.ClusterHostName = "Todo"
	//onboardingData.ClusterPrimary = "Todo"
	managementIface, errint := GetIfaceList("eth0")
	if errint < 0 {
		fmt.Errorf("Get ETH0 interfaces infomation failed")
		return
	}
	for _, iface := range managementIface {
		onboardingData.MacAddress = iface.HwAddr
		onboardingData.IpAddress = iface.IpAddr
		onboardingData.Netmask = iface.NetMask
		onboardingData.Vip = iface.Vip
		break
	}

	return
}

func (onboardHeader *A3OnboardingHeader) GetValue(ctx context.Context) {
	var config fetch.PfConfGeneral
	config.GetPfConfSub(ctx, &config.General)
	onboardHeader.Hostname = config.General.Hostname
	//onboardHeader.SystemID = "Todo"
	//onboardHeader.ClusterID = "Todo"
	//onboardHeader.SequenceID = "Todo"
	return
}

var ctxGlobal = log.LoggerNewContext(context.Background())

func GetOnboardingInfo(ctx context.Context) A3OnboardingInfo {
	var context context.Context
	onboardInfo := A3OnboardingInfo{}

	if ctx == nil {
		context = ctxGlobal
	} else {
		context = ctx
	}
	onboardInfo.Data.GetValue(context)
	onboardInfo.Header.GetValue(context)

	return onboardInfo
}
