//intchg.go implements geting interface changed info.
package a3share

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"strconv"
	"strings"
)

type A3IntChgHeader struct {
	A3OnboardingHeader
}

type A3IntChgData struct {
	MsgType    string        `json:"msgType"`
	Interfaces []A3Interface `json:"interfaces"`
}

type A3IntChgInfo struct {
	Header A3IntChgHeader `json:"header"`
	Data   A3IntChgData   `json:"data"`
}

func (intChgData *A3IntChgData) GetValue() {
	var ifullname string
	var services []string

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

		iname := strings.Split(iface.Name, ".")

		if len(iname) > 1 {
			ifullname = fmt.Sprintf("VLAN%s", iname[1])
		} else {
			ifullname = iname[0]
		}

		a3Interface.Vlan, _ = strconv.Atoi(iface.Vlan)
		a3Interface.IpAddress = iface.IpAddr
		a3Interface.Netmask = "255.255.255.0"
		a3Interface.Vip = iface.Vip
		a3Interface.Type = a3config.GetIfaceType(ifullname)
		a3Interface.Type = strings.ToUpper(a3Interface.Type)
		a3Interface.Type = "MANAGEMENT"
		//a3Interface.Service = []string{"PORTAL"}
		a3Interface.Service = a3config.GetIfaceServices(ifullname)
		for _, service := range a3Interface.Service {
			service = strings.ToUpper(service)
			services = append(services, service)
			//log.LoggerWContext(ctx).Error(service)
		}
		a3Interface.Service = services
		intChgData.Interfaces = append(intChgData.Interfaces, *a3Interface)
	}

	intChgData.MsgType = "interface-update"
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
