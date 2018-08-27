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
	iftype := strings.Split(GetIfaceElementVlaue(ifname, "type"), ",")
	if iftype[0] == "internal" {
		netsection := A3Read("NETWORKS", "all")
		for k, _ := range netsection {
			if netsection[k]["gateway"] == GetIfaceElementVlaue(ifname, "ip") {
				iftype = strings.Split(netsection[k]["type"], ",")
				/*need to delete vlan- for type*/
				Type := []rune(iftype[0])
				return string(Type[5:])
			}
		}
	}
	return iftype[0]
}

func GetIfaceServices(ifname string) []string {
	iftype := strings.Split(GetIfaceElementVlaue(ifname, "type"), ",")
	services := []string{}
	if len(iftype) > 0 {
		services = iftype[1:]
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
	if VlanInface(i.Name) {
		name := []rune(i.Name) /*need to delete vlan for name*/
		keyname := fmt.Sprintf("eth0.%s", string(name[4:]))

		if !utils.IfaceExists(keyname) {
			utils.CreateVlanIface("eth0", string(name[4:]))

		} else {
			ipold := GetIfaceElementVlaue(keyname, "ip")
			utils.DelIfaceIIpAddr(keyname, ipold)
		}
		utils.SetIfaceIIpAddr(keyname, i.IpAddr, i.NetMask)
	}

	err = UpdateInterface(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateVlanInterface error:" + err.Error())
	}
	err = UpdateNetconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
	}
	fmt.Println("UpdateNetconf commplite")
	return err
}

func DelInterface(ctx context.Context, i Item) error {
	return nil
}
