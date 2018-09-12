package utils

import (
	"context"
	"errors"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
	"net"
	"regexp"
	"strconv"
	"strings"
)

type Iface struct {
	Ifidx  int
	Name   string
	Master string // phy iface of vlan interface
	Active string
	HwAddr string
	Vlan   string

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

func CreateVlanIface(ifname string, vlan string) error {
	msg := ""
	if ifname == "all" || ifname == "lo" {
		msg = fmt.Sprintf("interface name(%s) err", ifname)
		return errors.New(msg)
	}

	iface, _ := GetIfaceList(ifname)
	if len(iface) == 0 {
		msg = fmt.Sprintf("get interface info err")
		return errors.New(msg)
	}

	cmd := fmt.Sprintf("sudo vconfig add %s %s", ifname, vlan)
	_, err := ExecShell(cmd)
	if err != nil {
		return err
	}

	return nil
}

func isIfaceActive(ifname string) bool {
	iface, _ := GetIfaceList(ifname)
	if len(iface) > 0 {
		return iface[0].Active == "UP"
	}

	return false
}

func IsVlanIface(ifname string) bool {
	vlan, _ := getIfaceVlan(ifname)
	if vlan == "" {
		return false
	}
	return true
}

func DelVlanIface(ifname string) error {
	msg := ""
	if !IfaceExists(ifname) {
		return nil
	}

	if !IsVlanIface(ifname) {
		msg = fmt.Sprintf("%s is not vlan interface", ifname)
		return errors.New(msg)
	}

	cmd := fmt.Sprintf("sudo vconfig rem %s", ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return err
	}

	//Todo: update pfconfig
	return nil
}

func SetIfaceUp(ifname string) error {
	cmd := fmt.Sprintf("sudo ip link set %s up", ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return err
	}
	return nil
}

func SetIfaceDown(ifname string) int {
	if ifname == "lo" || ifname == "all" {
		return -1
	}

	if !IfaceExists(ifname) {
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

func IfaceExists(ifname string) bool {
	_, err := GetIfaceList(ifname)
	if err < 0 {
		return false
	}
	return true
}

func IsIpExists(ip string) bool {
	cmd := fmt.Sprintf("sudo ping -c 1 -r %s -w 1", ip)
	_, err := ExecShell(cmd)
	if err != nil {
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

		ipmask := strings.Split(str[1], "/")
		item.IpAddr = ipmask[0]
		item.NetMask = ipmask[1]
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

func SetIfaceIIpAddr(ifname, ip, mask string) error {
	i := NetmaskStr2Len(mask)
	cmd := fmt.Sprintf("sudo ip addr add %s/%d broadcast 255.255.255.255 dev %s", ip, i, ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return err
	}
	return nil
}
func DelIfaceIIpAddr(ifname, ip string) error {
	cmd := fmt.Sprintf("sudo ip addr del %s dev %s", ip, ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		return err
	}
	return nil
}

func NetmaskLen2Str(a int) string {
	var k, sum int = 0, 0
	s := []string{}
	i := a / 8
	j := a % 8
	for k = 0; k < i; k++ {
		s = append(s, "255")
	}
	if i < 4 {
		for k = 0; k < j; k++ {
			sum = sum + int(1<<(uint)(7-k))
		}
		str := strconv.Itoa(sum)
		s = append(s, str)
		for k = 0; k < (4 - i - 1); k++ {
			s = append(s, "0")
		}
	}
	mask := strings.Join(s, ".")
	return mask
}

func NetmaskStr2Len(mask string) int {

	var num int = 0
	var value int
	sections := strings.Split(mask, ".")
	l := len(sections)
	if l != 4 {
		return 0
	}

	for k := 0; k < l; k++ {
		value, _ = strconv.Atoi(sections[k])
		for (value & 128) != 0 {
			num++
			value = value << 1
		}
	}

	return num
}

func IpBitwiseAndMask(ip, mask string) string {
	n := NetmaskStr2Len(mask)
	ipv4Addr := net.ParseIP(ip)
	ipv4Mask := net.CIDRMask(n, 32)

	str := fmt.Sprintf("%s", ipv4Addr.Mask(ipv4Mask))
	return str
}
func IsSameIpRange(ip1, ip2, mask string) bool {

	str1 := IpBitwiseAndMask(ip1, mask)
	str2 := IpBitwiseAndMask(ip2, mask)
	if str1 == str2 {
		return true
	}
	return false

}

// set gateway for interface
func setInterfaceGateway(ifname, gateway string) error {
	//cmd := fmt.Sprintf("sudo route add default gw %s %s", gateway, ifname)
	cmd := fmt.Sprintf("sudo ip route replace to default via %s dev %s", gateway, ifname)
	_, err := ExecShell(cmd)
	if err != nil {
		log.LoggerWContext(context.Background()).Info("exec" + cmd + "error")
		return err
	}

	return nil
}

func UpdateVlanIface(ifname string, vlan, ip, mask string) error {
	var err error
	if IfaceExists(ifname) {
		iface, _ := GetIfaceList(ifname)
		oldip := iface[0].IpAddr

		oldmasklen, _ := strconv.Atoi(iface[0].NetMask)
		if oldip != ip || oldmasklen != NetmaskStr2Len(mask) {
			//info := fmt.Sprintf("UpdateEthIface %s oldip(%s)-->ip(%s), oldmask(%s)-->newmask(%s)", ifname, oldip, ip, NetmaskLen2Str(oldmasklen), mask)
			//log.LoggerWContext(context.Background()).Info(info)
			err = DelIfaceIIpAddr(ifname, oldip)
			if err != nil {
				return err
			}
			/*check ip if is exsit*/
			if IsIpExists(ip) {
				msg := fmt.Sprintf("%s is exsit in net", ip)
				return errors.New(msg)
			}

			err = SetIfaceIIpAddr(ifname, ip, mask)
			if err != nil {
				return err
			}
			if !isIfaceActive(ifname) {
				err = SetIfaceUp(ifname)
				if err != nil {
					return err
				}
			}
		}

	} else {
		CreateVlanIface("eth0", vlan)
		/*check ip if is exsit*/
		if IsIpExists(ip) {
			msg := fmt.Sprintf("%s is exsit in net", ip)
			return errors.New(msg)
		}
		err = SetIfaceIIpAddr(ifname, ip, mask)
		if err != nil {
			return err
		}
		if !isIfaceActive(ifname) {
			err = SetIfaceUp(ifname)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func UpdateEthIface(ifname string, ip, mask string) error {
	var err error
	gateway := GetA3DefaultGW()
	iface, _ := GetIfaceList(ifname)
	oldip := iface[0].IpAddr
	oldmasklen, _ := strconv.Atoi(iface[0].NetMask)
	if oldip != ip || oldmasklen != NetmaskStr2Len(mask) {
		info := fmt.Sprintf("UpdateEthIface %s oldip(%s)-->ip(%s), oldmask(%s)-->newmask(%s)", ifname, oldip, ip, NetmaskLen2Str(oldmasklen), mask)
		fmt.Println(info)
		log.LoggerWContext(context.Background()).Info(info)
		/*new ip must be the same net range with the old ip */
		if !IsSameIpRange(ip, oldip, mask) {
			msg := fmt.Sprintf("new ip(%s) is not same net range with oldip(%s)", ip, oldip)
			return errors.New(msg)
		}
		/*check ip if is exsit*/
		/*check ip if is exsit*/
		if IsIpExists(ip) {
			msg := fmt.Sprintf("%s is exsit in net", ip)
			return errors.New(msg)
		}

		err = DelIfaceIIpAddr(ifname, oldip)
		if err != nil {
			return err
		}
		log.LoggerWContext(context.Background()).Info("DelIfaceIIpAddr OK:")
		err = SetIfaceIIpAddr(ifname, ip, mask)
		if err != nil {
			return err
		}
		log.LoggerWContext(context.Background()).Info("SetIfaceIIpAddr OK:")
		err = setInterfaceGateway(ifname, gateway)
		if err != nil {
			return err
		}
		log.LoggerWContext(context.Background()).Info("setInterfaceGateway OK:")
		if !isIfaceActive(ifname) {
			err = SetIfaceUp(ifname)
			if err != nil {
				return err
			}
		}
	}
	return nil
}
