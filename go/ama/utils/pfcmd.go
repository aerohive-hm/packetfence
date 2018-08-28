package utils

import (
	"context"
	//"errors"
	"fmt"
	//"regexp"
	"github.com/inverse-inc/packetfence/go/log"
	"strconv"
	"strings"
)

const (
	pfcmd     = A3Root + "/bin/pfcmd "
	pfconfig  = "sudo " + pfcmd + "pfconfig "
	pfservice = "sudo " + pfcmd + "service "
)

type Service struct {
	Name            string
	ShouldBeStarted string
	Pid             string
}

var ctx = context.Background()

func pfExpire(ns string) {
	cmd := pfconfig + " expire" + " " + ns
	ExecShell(cmd)
}

func ReloadConfig() {
	pfExpire("all")
}

func restartPfconfig() (string, error) {
	cmd := `setsid sudo service packetfence-config restart 2>&1`
	return ExecShell(cmd)
}

func serviceCmdBackground(cmd string) (string, error) {
	return ExecShell("setsid " + cmd + " &>/dev/null &")
}

func StartPfServices() (string, error) {
	cmd := pfservice + "pf updatesystemd"
	return ExecShell(cmd)
}

func updateCurrentlyAt() {
	cmd := "cp -f " + A3Release + " " + A3CurrentlyAt
	ExecShell(cmd)
}

// only Start Services during initial setup
func StartService() error {
	if IsFileExist(A3CurrentlyAt) {
		return nil
	}

	out, err := StartPfServices()
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	out, err = restartPfconfig()
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	out, err = serviceCmdBackground(pfservice + "pf start")
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	updateCurrentlyAt()
	return nil
}

func ServiceStatus() error {
	cmd := pfservice + "pf status"
	ret, err := ExecShell(cmd)
	lines := strings.Split(ret, "\n")
	if len(lines) < 1 {
		return err
	}

	toBeStarted := 0
	started := 0
	for _, l := range lines {
		vals := strings.Split(l, "|")
		if len(vals) < 3 {
			continue
		}
		i, err := strconv.Atoi(vals[1])
		if err != nil {
			continue
		}

		toBeStarted += i

		i, err = strconv.Atoi(vals[2])
		if err != nil || i <= 0 {
			continue
		}
		started++
	}
	fmt.Println(toBeStarted, started)
	return nil
}
