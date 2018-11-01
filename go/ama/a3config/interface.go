package a3config

import (
	"context"
	"errors"
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

	if strings.Contains(ifname, ".") {
		netsection := A3Read("NETWORKS", "all")
		for k, _ := range netsection {
			if netsection[k]["gateway"] == GetIfaceElementVlaue(ifname, "ip") {
				if netsection[k]["type"] == "" {
					return ""
				}
				s := strings.Split(strings.ToUpper(netsection[k]["type"]), ",")
				/*need to delete vlan- for type*/
				if strings.Contains(s[0], "VLAN-") {
					Type := []rune(s[0])
					return string(Type[5:])
				}
				return s[0]
			}
		}
	}
	/*if vlan  type is portal ,should get type form pf.conf*/
	iftype := GetIfaceElementVlaue(ifname, "type")
	if iftype == "" {
		if strings.Contains(ifname, ".") {
			return ""
		} else {
			return "MANAGEMENT"
		}
	}
	s := strings.Split(strings.ToUpper(iftype), ",")
	return s[0]

}

func GetIfaceServices(ifname string) []string {
	services := []string{}
	iftype := GetIfaceElementVlaue(ifname, "type")
	if iftype == "" {
		if !strings.Contains(ifname, ".") {
			services = append(services, "RADIUS")
		}
		return services
	}
	s := strings.Split(strings.ToUpper(iftype), ",")
	for _, value := range s {
		if value == "HIGH-AVAILABILITY" {
			continue
		}
		services = append(services, value)
	}
	return services[1:]
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
	/*check new inteface if exist*/
	ifname := ChangeUiIfname(i.Name, i.Prefix)
	if utils.IfaceExists(ifname) {
		msg = fmt.Sprintf("%s is exist in system", i.Name)
		return errors.New(msg)
	}
	return nil
}
func UpdateInterfaceInfo(ctx context.Context, i Item) error {
	err := UpdateInterface(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update Interface error:" + err.Error())
		return err
	}
	err = UpdateNetconf(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
		return err
	}
	err = UpdatePrimaryClusterconf(!Isclusterjoin, i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdatePrimaryClusterconf error:" + err.Error())
		return err
	}
	return err
}
func UpdateSystemInterface(ctx context.Context, i Item) error {
	var err error
	/*delete original interface*/
	items := GetItemsValue(ctx)
	for _, item := range items {
		if i.Original == item.Original {
			if i.Name != item.Name {
				err = DelSystemInterface(ctx, item)
				if err != nil {
					return err
				}
				err = CreateSystemInterface(ctx, i)
				return err
			}
		}
	}
	err = UpdateInterfaceInfo(ctx, i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateInterfaceInfo:" + err.Error())
		return err
	}
	return err
}

func CreateSystemInterface(ctx context.Context, i Item) error {
	err := CheckCreateIfValid(i)
	if err != nil {
		log.LoggerWContext(ctx).Error("CheckCreateIfValid:" + err.Error())
		return err
	}
	err = UpdateInterfaceInfo(ctx, i)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateInterfaceInfo:" + err.Error())
		return err
	}
	return err
}

func DelSystemInterface(ctx context.Context, i Item) error {
	var err error
	ifname := ChangeUiIfname(i.Name, i.Prefix)
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

func ChangeUiIfname(uiifname, prefix string) string {
	var ifname string
	if VlanInface(uiifname) {
		name := []rune(uiifname) /*need to delete vlan for name*/
		ifname = fmt.Sprintf("%s.%s", prefix, string(name[4:]))

	} else {
		ifname = uiifname
	}
	return ifname
}
