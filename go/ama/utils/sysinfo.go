package utils

import (
	"fmt"
	"strings"
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
	clis := []Clis{
		{
			cmd: "hostnamectl set-hostname" + hostname,
		},
		{
			cmd: `sed -i -r "s/HOSTNAME=[-_A-Za-z0-9]+/HOSTNAME=` +
				hostname + `/" /etc/sysconfig/network`,
		},
	}
	ExecClis(clis)
}
