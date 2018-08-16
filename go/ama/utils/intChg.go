package utils

import (
	"fmt"
	"context"
	"github.com/inverse-inc/packetfence/go/log"
)

type A3IntChgHeader struct {
	A3OnboardingHeader
}

type A3IntChgData struct {
	MsgType	string 	`json:"msgType"`
	Interfaces      []A3Interface `json:"interfaces"`
}

type A3IntChgInfo struct {
	Header 	A3IntChgHeader	`json:"header"`
	Data 	A3IntChgData	`json:"data"`
}

func (intChgData *A3IntChgData) GetValue() {
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
		intChgData.Interfaces = append(intChgData.Interfaces, *a3Interface)
	}

	intChgData.MsgType = "interface-change"
}

var contextIntChg = log.LoggerNewContext(context.Background())

func GetIntChgInfo(ctx context.Context) A3IntChgInfo {
	var context context.Context
	intChgInfo := A3IntChgInfo{}

	if ctx == nil {
		context = contextIntChg
	} else {
		context = ctx
	}
	intChgInfo.Header.GetValue(context)
	intChgInfo.Data.GetValue()

	return intChgInfo
}
