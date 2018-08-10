//onboarding.go implements handling REST API:
/*
 *	/a3/api/v1/event/onboarding
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/pfconfigdriver"
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

//Fetch and Convert A3 onboarding infomation To Json
func (a3Data *A3OnboardingInfo) GetMethodHandle(ctx context.Context) ([]byte, error) {
	onboardingInfo := GetOnboardingInfo(ctx)
	fmt.Println("onboardingInfo:\n", onboardingInfo)

	jsonData, err := json.Marshal(onboardingInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return nil, err
	}
	return jsonData, nil
}

func GetOnboardingInfo(ctx context.Context) A3OnboardingInfo {
	onboardInfo := A3OnboardingInfo{}
	//Todo: onboarding info should be got from A3 system, instead of hard code.
	var generalConf pfconfigdriver.PfConfGeneral
	generalConf.PfconfigMethod = "hash_element"
	generalConf.PfconfigNS = "config::Pf"
	generalConf.PfconfigHashNS = "general"
	pfconfigdriver.FetchDecodeSocket(ctx, &generalConf)

	onboardInfo.Header.Hostname = generalConf.Hostname
	onboardInfo.Header.SystemID = "47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9B72"
	onboardInfo.Header.ClusterID = "1C45299D-DB95-4C7F-A787-219C327971BA"
	onboardInfo.Header.SequenceID = "a738c4da-e5ae-43e0-957a-25d3363e0100"

	onboardInfo.Data.Msgtype = "connect"
	onboardInfo.Data.MacAddress = "0019770004B0"
	onboardInfo.Data.IpMode = "DHCP"
	onboardInfo.Data.IpAddress = "10.16.0.1"
	onboardInfo.Data.Netmask = "255.255.255.0"
	onboardInfo.Data.DefaultGateway = "10.16.0.254"
	onboardInfo.Data.SoftwareVersion = "2.0"
	onboardInfo.Data.SystemUptime = 1532942958060
	onboardInfo.Data.Vip = "10.16.0.11"
	onboardInfo.Data.ClusterHostName = "A3-Cluster-1"
	onboardInfo.Data.ClusterPrimary = true

	interfaceOne := A3Interface{"ETH0", "null", "10.16.0.1", "10.16.0.11", "255.255.255.0", "MANAGEMENT", []string{}, "ETH0"}
	interfaceTwo := A3Interface{"ETH0", "10", "10.16.0.2", "10.16.0.12", "255.255.255.0", "REGISTRATION", []string{"PORTAL"}, "ETH0 VLAN 10"}
	interfaceThree := A3Interface{Parent: "ETH1", Vlan: "30", IpAddress: "10.16.0.5", Vip: "10.16.0.15", Netmask: "255.255.255.0", Type: "PORTAL", Service: []string{"PORTAL", "RADIUS"}, Description: "ETH1 VLAN 30"}
	onboardInfo.Data.Interfaces = append(onboardInfo.Data.Interfaces, interfaceOne)
	onboardInfo.Data.Interfaces = append(onboardInfo.Data.Interfaces, interfaceTwo)
	onboardInfo.Data.Interfaces = append(onboardInfo.Data.Interfaces, interfaceThree)

	return onboardInfo
}
