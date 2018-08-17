package utils

import (
	"fmt"
	"strings"
)

func GetA3Version() string {
	cmd := "pfcmd version"
	out, err := ExecShell(cmd)
	if err != nil {
		fmt.Println("exec error")
		return ""
	}
	i := strings.Index(out, "\n")
	return out[:i]
}

func GetSysUptime() int64 {
	return uptime()
}
