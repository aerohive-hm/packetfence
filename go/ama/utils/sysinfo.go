package utils

import (
	"fmt"
	//	"strconv"
	"strings"
	"time"
)

func GetA3Version() string {
	cmd := "pfcmd version"
	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return ""
	}
	i := strings.Index(out, "\n")
	return out[:i]
}

func GetSysUptime() int64 {
	return uptime()
}

func GetA3SysId() string {
	cmd := "cat /etc/A3.systemid"

	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("%s:exec error", cmd)
		return ""
	}
	return out
}

func SetHostname(hostname string) {
	cmds := []string{
		fmt.Sprintf(`hostnamectl set-hostname "%s" --static`, hostname),
		`sed -i -r "s/HOSTNAME=[-_\.A-Za-z0-9]+/HOSTNAME=` +
			hostname + `/" /etc/sysconfig/network`,
		fmt.Sprintf(`echo 127.0.0.1 %s >> /etc/hosts`, hostname),
	}
	ExecCmds(cmds)
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
