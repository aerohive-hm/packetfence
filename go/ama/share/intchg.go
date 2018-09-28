//intchg.go implements geting interface changed info.
package a3share

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"strconv"
)

type A3IntChgHeader struct {
	A3OnboardingHeader
}

type A3IntChgData struct {
	MsgType    	string        	`json:"msgType"`
	IpMode	   	string        	`json:"ipMode"`
	DefaultGateway  string     	`json:"defaultGateway"`
	Interfaces 	[]A3Interface 	`json:"interfaces"`
}

type A3IntChgInfo struct {
	Header A3IntChgHeader `json:"header"`
	Data   A3IntChgData   `json:"data"`
}

func (intChgData *A3IntChgData) GetValue() {
	ifaces, errint := utils.GetIfaceList("all")
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

		a3Interface.Vlan, _ = strconv.Atoi(iface.Vlan)
		a3Interface.IpAddress = iface.IpAddr
		value, _ := strconv.Atoi(iface.NetMask)
		a3Interface.Netmask = utils.NetmaskLen2Str(value)
		a3Interface.Vip = a3config.ClusterNew().GetPrimaryClusterVip(iface.Name)
		a3Interface.Type = a3config.GetIfaceType(iface.Name)
		a3Interface.Service = a3config.GetIfaceServices(iface.Name)
		intChgData.Interfaces = append(intChgData.Interfaces, *a3Interface)
	}

	intChgData.MsgType = "interface-update"
	intChgData.IpMode = "STATIC"
	intChgData.DefaultGateway = utils.GetA3DefaultGW()
}

var contextIntChg = log.LoggerNewContext(context.Background())

func GetIntChgInfo(ctx context.Context) []A3IntChgInfo {
	var context context.Context
	var changeMsg []A3IntChgInfo
	intChgInfo := A3IntChgInfo{}

	if ctx == nil {
		context = contextIntChg
	} else {
		context = ctx
	}
	intChgInfo.Header.GetValue(context)
	intChgInfo.Data.GetValue()

	changeMsg = append(changeMsg, intChgInfo)
	return changeMsg
}
