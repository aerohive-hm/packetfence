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
type A3License struct {
	LicensedCapacity    uint16 `json:"licensedCapacity"`
	CurrentUsedCapacity uint16 `json:"currentUsedCapacity"`
	AverageUsedCapacity uint16 `json:"averageUsedCapacity"`
	NextExpirationDate  uint64 `json:"nextExpirationDate"`
}

type A3OnboardingData struct {
	Msgtype         string        `json:"msgtype"`
	MacAddress      string        `json:"macAddress"`
	IpMode          string        `json:"ipMode"`
	IpAddress       string        `json:"ipaddress"`
	Netmask         string        `json:"netmask"`
	DefaultGateway  string        `json:"defaultGateway"`
	SoftwareVersion string        `json:"softwareVersion"`
	SystemUptime    int64         `json:"systemUpTime"`
	Vip             string        `json:"vip"`
	ClusterHostName string        `json:"clusterHostName"`
	ClusterPrimary  bool          `json:"clusterPrimary"`
	Interfaces      []A3Interface `json:"interfaces"`
	License         A3License     `json:"license"`
}

type A3OnboardingHeader struct {
	SystemID  string `json:"systemId"`
	ClusterID string `json:"clusterId"`
	Hostname  string `json:"hostname"`
	MessageID string `json:"messageId"`
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
	onboardingData.SoftwareVersion = GetA3Version()
	onboardingData.SystemUptime = GetSysUptime()
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

	//Fetch license info, not hard code, need todo
	onboardingData.License.LicensedCapacity = 5
	onboardingData.License.CurrentUsedCapacity = 3
	onboardingData.License.AverageUsedCapacity = 2
	onboardingData.License.NextExpirationDate = 4102415999000

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

var contextOnboard = log.LoggerNewContext(context.Background())

func GetOnboardingInfo(ctx context.Context) A3OnboardingInfo {
	var context context.Context
	onboardInfo := A3OnboardingInfo{}

	if ctx == nil {
		context = contextOnboard
	} else {
		context = ctx
	}
	onboardInfo.Data.GetValue(context)
	onboardInfo.Header.GetValue(context)

	return onboardInfo
}
