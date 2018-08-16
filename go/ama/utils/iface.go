package utils

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

type Iface struct {
	Ifidx   int
	Name    string
	Master  string // phy iface of vlan interface
	Active  string
	HwAddr  string
	Vlan    string
	IpAddr  string
	IpMode  string // DHCP or Static
	NetMask string
	Vip     string // Virtual IP
}

func getIfaceVlan(ifname string) (string, int) {
	ret := strings.Split(ifname, ".")
	if len(ret) > 1 {
		return ret[1], 0
	}
	return "", 0
}

func CreateVlanIface(ifname string, vlan string) int {
	if ifname == "all" || ifname == "lo" {
		return -1
	}

	iface, _ := GetIfaceList(ifname)
	if len(iface) == 0 {
		return -1
	}

	cmd := fmt.Sprintf("sudo vconfig add %s %s", ifname, vlan)
	_, err := ExecShell(cmd)
	if err != nil {
		return -1
	}

	return 0
}

func isIfaceActive(ifname string) bool {
	iface, _ := GetIfaceList(ifname)
	if len(iface) > 0 {
		return iface[0].Active == "UP"
	}

	return false
}

func isVlanIface(ifname string) bool {
	vlan, _ := getIfaceVlan(ifname)
	if vlan == "" {
		return false
	}
	return true
}

func DelVlanIface(ifname string) int {
	if !ifaceExists(ifname) {
		return 0
	}

	if !isVlanIface(ifname) {
		return -1
	}

	cmd := fmt.Sprintf("sudo vconfig rem %s", ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return -1
	}

	//Todo: update pfconfig
	return 0
}

func SetIfaceUp(ifname string) int {
	cmd := fmt.Sprintf("sudo ip link set %s up", ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return -1
	}
	return 0
}

func SetIfaceDown(ifname string) int {
	if ifname == "lo" || ifname == "all" {
		return -1
	}

	if !ifaceExists(ifname) {
		return -1
	}

	if !isIfaceActive(ifname) {
		return 0
	}

	cmd := fmt.Sprintf("sudo ip link set %s down", ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return -1
	}

	return 0
}

func ifaceExists(ifname string) bool {
	_, err := GetIfaceList(ifname)
	if err < 0 {
		return false
	}
	return true
}

func GetIfaceList(ifname string) ([]Iface, int) {
	var list []Iface
	ipcmd := map[string]string{
		"link": "sudo ip -4 -o link show",
		"addr": "sudo ip -4 -o addr show",
	}

	cmd := ipcmd["link"]
	if ifname != "all" {
		cmd += " " + ifname
	}

	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("exec error")
		return nil, -1
	}

	re := `(\d+):\s([\w]+)(?:\.([\d]+))?(?:\@([^:]+))?.+\sstate\s(\S+).+ether\s(\S+)`
	r := regexp.MustCompile(re)
	ret := r.FindAllStringSubmatch(out, -1)

	addIface := func(ifname string, val []string) (item Iface, err error) {
		item.Ifidx, err = strconv.Atoi(val[1])
		if err != nil {
			return Iface{}, err
		}
		if val[3] == "" {
			item.Name = val[2]
		} else {
			item.Name = val[2] + "." + val[3]
		}
		item.Vlan = val[3]
		item.Master = val[4]
		item.Active = val[5]
		item.HwAddr = val[6]
		return item, nil
	}

	updateIface := func(item *Iface, val []string) error {
		cmd = ipcmd["addr"] + " " + item.Name
		out, err = ExecShell(cmd)
		if err != nil {
			return err
		}
		re = `\binet (([^\/]+)\/\d+)`
		r := regexp.MustCompile(re)
		str := r.FindStringSubmatch(out)
		if len(str) == 0 {
			return err
		}
		item.IpAddr = str[2]
		return nil
	}

	for _, v := range ret {
		item, err := addIface(ifname, v)
		if err != nil {
			continue
		}
		err = updateIface(&item, v)
		if err != nil {
			continue
		}
		list = append(list, item)
	}

	return list, 0
}
