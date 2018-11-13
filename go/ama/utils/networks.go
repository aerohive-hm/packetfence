// Networks tool for system
package utils

import (
	"fmt"
	"strings"
	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/log"
)

// Get A3 default gateway
func GetA3DefaultGW() string {
	cmd := "LANG=C sudo ip route show to 0/0"

	// result looks like: default via 10.155.61.254 dev eth0 proto static metric 100
	result, err := ExecShell(cmd, false)
	if err != nil {
		log.LoggerWContext(ama.Ctx).Error(cmd + ":exec error")
		return ""
	}

	vals := strings.Split(result, " ")

	if len(vals) > 3 {
		return vals[2]
	}

	return ""
}

func GetIpAddr(ifname string) string {
	managementIface, errint := GetIfaceList(ifname)
	if errint < 0 {
		fmt.Errorf("Get interfaces infomation failed")
		return ""
	}
	for _, iface := range managementIface {
		return iface.IpAddr
	}
	return ""
}

