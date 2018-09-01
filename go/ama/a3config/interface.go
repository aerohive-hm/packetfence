package a3config

import (
	"context"
	"fmt"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

func GetIfaceElementVlaue(ifname, element string) string {
	ifacefullname := fmt.Sprintf("interface %s", ifname)
	Section := ReadIface(ifacefullname)
	value := Section[ifacefullname][element]
	return value
}

func GetIfaceType(ifname string) string {
	iftype := strings.Split(strings.ToUpper(GetIfaceElementVlaue(ifname, "type")), ",")
	if strings.Contains(ifname, ".") {
		netsection := A3Read("NETWORKS", "all")
		for k, _ := range netsection {
			if netsection[k]["gateway"] == GetIfaceElementVlaue(ifname, "ip") {
				iftype = strings.Split(strings.ToUpper(netsection[k]["type"]), ",")
				/*need to delete vlan- for type*/
				Type := []rune(iftype[0])
				return string(Type[5:])
			}
		}
	}
	return iftype[0]
}

func GetIfaceServices(ifname string) []string {
	services := []string{}
	iftype := strings.ToUpper(GetIfaceElementVlaue(ifname, "type"))
	if iftype == "" {
		return services
	}
	s := strings.Split(iftype, ",")
	l := len(s)
	if strings.Contains(iftype, "HIGH-AVAILABILITY") {
		services = s[1 : l-1]
	} else {
		services = s[1:]
	}

	return services
}

func VlanInface(infacename string) bool {
	if strings.Contains(infacename, "VLAN") {
		return true
	}
	return false
}

func UpdateSystemInterface(ctx context.Context, i Item) error {
	var err error

	err = UpdateInterface(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update Interface error:" + err.Error())
	}
	err = UpdateNetconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
	}
	err = UpdatePrimaryClusterconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdatePrimaryClusterconf error:" + err.Error())
	}
	return err
}

func DelSystemInterface(ctx context.Context, i Item) error {
	var err error
	var sectionId string

	if VlanInface(i.Name) {
		name := []rune(i.Name) /*need to delete vlan for name*/
		keyname := fmt.Sprintf("eth0.%s", string(name[4:]))
		sectionId = fmt.Sprintf("interface %s", keyname)
		utils.DelVlanIface(keyname)
	} else {
		sectionId = fmt.Sprintf("interface %s", strings.ToLower(i.Name))
	}

	err = A3Delete("PF", sectionId)

	err = DeleteNetconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("DeleteNetconf error:" + err.Error())
	}
	err = DeletePrimaryClusterconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("DeletePrimaryClusterconf error:" + err.Error())
	}
	return nil
}

func ChangeUiInterfacename(uiifname string) string {
	var ifname string
	if VlanInface(uiifname) {
		name := []rune(uiifname) /*need to delete vlan for name*/
		ifname = fmt.Sprintf("eth0.%s", string(name[4:]))

	} else {
		ifname = uiifname
	}
	return ifname
}
