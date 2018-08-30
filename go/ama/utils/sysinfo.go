package utils

import (
	"fmt"
	"strconv"
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

//func SetA3SysId(Id string) error {
//	cmd := fmt.Sprintf("echo \"%s\" > /etc/A3.systemid", Id)

//	out, err := ExecShell(cmd)
//	if err != nil {
//		fmt.Println("%s:exec error", cmd)
//		return err
//	}
//	return nil
//}

func SetHostname(hostname string) {
	cmds := []string{
		"hostnamectl set-hostname " + hostname,
		`sed -i -r "s/HOSTNAME=[-_A-Za-z0-9]+/HOSTNAME=` +
			hostname + `/" /etc/sysconfig/network`,
	}
	ExecCmds(cmds)
}

func waitProcStop(proc string) {
	cmd := "pgrep " + proc
	for {
		_, err := ExecShell(cmd)
		if err == nil {
			break
		}
		time.Sleep(time.Duration(3) * time.Second)
	}
}

func waitProcStart(proc string) {
	cmd := "pgrep " + proc
	for {
		_, err := ExecShell(cmd)
		if err != nil {
			break
		}
		time.Sleep(time.Duration(3) * time.Second)
	}
}

func killPorc(proc string) error {
	cmd := "pgrep " + proc
	out, err := ExecShell(cmd)
	if err != nil {
		return nil
	}

	for pid := range cmd {
		i, err := strconv.Atoi(pid)
		if err != nil {
			continue
		}
	}
}
