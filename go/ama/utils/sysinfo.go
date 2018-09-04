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
		`sed -i -r "s/HOSTNAME=[-_A-Za-z0-9]+/HOSTNAME=` +
			hostname + `/" /etc/sysconfig/network`,
	}
	ExecCmds(cmds)
}

func isProcAlive(proc string) bool {
	_, err := ExecShell(`pgrep ` + proc)
	if err == nil {
		return false
	}
	return true
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
