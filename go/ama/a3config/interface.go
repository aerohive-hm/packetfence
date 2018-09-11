package a3config

import (
	"context"
	"errors"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"strings"
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

func CheckCreateIfValid(i Item) error {
	msg := ""
	isvlan := VlanInface(i.Name)
	if !isvlan {
		return nil
	}
	/*check new inteface if exsit*/
	ifname := ChangeUiInterfacename(i.Name)
	if utils.IfaceExists(ifname) {
		msg = fmt.Sprintf("%s is exsit in system", i.Name)
		return errors.New(msg)
	}
	/*check ip if exsit*/
	ifaces, errint := utils.GetIfaceList("all")
	if errint < 0 {
		msg = fmt.Sprintf("Get interfaces infomation failed.")
		return errors.New(msg)
	}
	for _, iface := range ifaces {
		if i.IpAddr == iface.IpAddr {
			msg = fmt.Sprintf("the ip address (%s) is exsit in system.", i.IpAddr)
			return errors.New(msg)
		}
	}
	return nil
}
func UpdateSystemInterface(ctx context.Context, i Item) error {
	var err error
	/*delete original interface*/
	items := GetItemsValue(ctx)
	for _, item := range items {
		if i.Original == item.Original {
			err = DelSystemInterface(ctx, item)
			if err != nil {
				return err
			}
			break
		}
	}
	err = CreateSystemInterface(ctx, i)
	return err
}

func CreateSystemInterface(ctx context.Context, i Item) error {
	err := CheckCreateIfValid(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("CheckCreateIfValid:" + err.Error())
		return err
	}
	err = UpdateInterface(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update Interface error:" + err.Error())
		return err
	}
	err = UpdateNetconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
		return err
	}
	err = UpdatePrimaryClusterconf(true, i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdatePrimaryClusterconf error:" + err.Error())
		return err
	}
	return err
}

func DelSystemInterface(ctx context.Context, i Item) error {
	var err error
	ifname := ChangeUiInterfacename(i.Name)
	sectionId := []string{fmt.Sprintf("interface %s", ifname)}
	if VlanInface(i.Name) {
		utils.DelVlanIface(ifname)
	}
	err = A3Delete("PF", sectionId)
	if err != nil {
		log.LoggerWContext(ctx).Error("Deleteinterface error:" + err.Error())
		return err
	}
	err = DeleteNetconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("DeleteNetconf error:" + err.Error())
		return err
	}
	err = DeletePrimaryClusterconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("DeletePrimaryClusterconf error:" + err.Error())
		return err
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
