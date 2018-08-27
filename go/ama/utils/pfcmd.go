package utils

import (
	//	"fmt"
	//	"strings"
	"errors"
	//	"github.com/inverse-inc/packetfence/go/log"
)

const (
	pfcmd     = A3Root + "bin/pfcmd"
	pfconfig  = "sudo pfcmd pfconfig"
	pfservice = "sudo pfcmd service"
)

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

func StartPfServices() (string, error) {
	cmd := pfservice + "  pf updatesystemd"
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
		return errors.New(out)
	}

	out, err = restartPfconfig()
	if err != nil {
		return errors.New(out)
	}

	updateCurrentlyAt()
	return nil
}
