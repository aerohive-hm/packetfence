package a3config

import (
	"fmt"
	"strings"
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
