package utils

import (
	"context"
	"errors"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
	"regexp"
	"strconv"
	"strings"
	"time"
	"golang.org/x/sys/unix"
)

type SysHealth struct {
	CpuRate  float64
	MemTotal float64
	MemUsed  float64
}

//The returned value using Millisecond as the unit
func GetSysUptime() int64 {
	var sysinfo unix.Sysinfo_t

	err := unix.Sysinfo(&sysinfo)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get system info failed:" + err.Error())
		return 0
	}

	return sysinfo.Uptime * 1000
}

func GetA3Version() string {
	cmd := "pfcmd version"
	out, err := ExecShell(cmd)
	if err != nil {
		return ""
	}
	i := strings.Index(out, "\n")
	return out[:i]
}

func GetAMAUptime() int64 {
	return uptime()
}

func GetA3SysId() string {
	cmd := "cat /etc/A3.systemid"

	out, err := ExecShell(cmd)
	if err != nil {
		return ""
	}
	return out
}

func SetHostname(hostname string) error {
	cmd := fmt.Sprintf(`hostnamectl set-hostname "%s" --static`, hostname)
	_, err := ExecShell(cmd)
	if err != nil {
		msg := fmt.Sprintf("set hostname (%s) failed, please check if it is valid", hostname)
		return errors.New(msg)
	}
	cmds := []string{
		`sed -i -r "s/HOSTNAME=[-_\.A-Za-z0-9]+/HOSTNAME=` +
			hostname + `/" /etc/sysconfig/network`,
		fmt.Sprintf(`echo 127.0.0.1 %s >> /etc/hosts`, hostname),
	}
	ExecCmds(cmds)
	return nil
}

func GetHostname() string {
	h, _ := ExecShell(`hostname`)
	return strings.TrimRight(h, "\n")
}

func isProcAlive(proc string) bool {
	_, err := ExecShell(`pgrep ` + proc)
	if err == nil {
		return true
	}
	return false
}

func waitProcStop(proc string) {
	for {
		_, err := ExecShell(`pgrep ` + proc)
		if err != nil {
			break
		}
		time.Sleep(time.Duration(3) * time.Second)
	}
}

func waitProcStart(proc string) {
	for {
		_, err := ExecShell(`pgrep ` + proc)
		if err == nil {
			break
		}
		time.Sleep(time.Duration(3) * time.Second)
	}
}

func killPorc(proc string) {
	cmd := "pgrep " + proc
	out, err := ExecShell(cmd)
	if err != nil {
		return
	}

	pids := strings.Split(out, "\n")
	for _, pid := range pids {
		if pid != "" {
			ExecShell(`kill ` + pid)
		}
	}

	waitProcStop(proc)
}

func updateEtcd() {
	cmds := []string{
		`systemctl stop packetfence-etcd`,
		`rm -rf /usr/local/pf/var/etcd/`,
	}
	ExecCmds(cmds)
}

func GetOwnMGTIp() string {
	ifaces, _ := GetIfaceList("eth0")
	for _, iface := range ifaces {
		return iface.IpAddr
	}

	return ""
}

func getCpuRate(buf string) float64 {
	r := regexp.MustCompile(`%Cpu\(s\):.*?([\d\.]+)\s+id`)
	ret := r.FindStringSubmatch(buf)
	if len(ret) < 2 {
		return -1
	}

	f, err := strconv.ParseFloat(ret[1], 64)
	if err != nil {
		return -1
	}

	return 100.0 - f
}

func getMemInfo(buf string) (memTotal, memUsed float64) {
	r := regexp.MustCompile(`[KM]iB Mem.*?([\d\.]+)\s+total.*?([\d\.]+)\s+used`)
	ret := r.FindStringSubmatch(buf)
	if len(ret) < 3 {
		return -1, -1
	}

	total, err := strconv.ParseFloat(ret[1], 64)
	if err != nil {
		return -1, -1
	}

	used, err := strconv.ParseFloat(ret[2], 64)
	if err != nil {
		return total, -1
	}

	return total, used
}

func GetCpuMem() SysHealth {
	var info SysHealth
	out, err := ExecShell(`top -b -n 1 | head -n 5`)
	if err != nil {
		return SysHealth{}
	}

	info.CpuRate = getCpuRate(out)
	info.MemTotal, info.MemUsed = getMemInfo(out)

	return info
}
