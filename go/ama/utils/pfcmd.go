package utils

import (
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

func pfExpire(ns string) {
	cmd := pfconfig + " expire " + ns
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

func UpdatePfServices() []Clis {
	cmds := []string{
		pfservice + "pf updatesystemd",
		pfcmd + "configreload hard",
	}
	return ExecCmds(cmds)
}

func updateCurrentlyAt() {
	cmd := "cp -f " + A3Release + " " + A3CurrentlyAt
	ExecShell(cmd)
}

func initClusterDB() {
	cmds := []string{
		pfcmd + "checkup",
		`systemctl set-default packetfence-cluster`,
		`systemctl stop packetfence-mariadb`,
	}
	ExecCmds(cmds)
	waitProcStop("mysqld")
	cmds = []string{
		pfcmd + "generatemariadbconfig",
		A3Root + `/sbin/pf-mariadb --force-new-cluster &`,
	}

	ExecCmds(cmds)
}

func initStandAloneDb() {
	cmds := []string{
		pfcmd + "checkup",
		`systemctl stop packetfence-mariadb`,
	}
	ExecCmds(cmds)
	waitProcStop("mysqld")
	ExecShell(`systemctl start packetfence-mariadb`)
}

// only Start Services during initial setup
func InitStartService() error {
	UpdatePfServices()

	out, err := restartPfconfig()
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	waitProcStart("pfconfig")
	if IsFileExist(A3Root + "conf/cluster.conf") {
		go initClusterDB()
	} else {
		initStandAloneDb()
	}
	waitProcStart("mysqld")

	out, err = serviceCmdBackground(pfservice + "pf start")
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	updateCurrentlyAt()
	return nil
}

func ForceNewCluster() {
	cmds := []string{
		pfcmd + "configreload hard",
		pfcmd + "checkup",
		"systemctl stop packetfence-mariadb",
		pfcmd + "generatemariadbconfig",
		A3Root + `/sbin/pf-mariadb --force-new-cluster &`,
	}

	ExecCmds(cmds)
}

// prepare for the new cluster mode
func StopService() {
	cmds := []string{
		`systemctl start packetfence-mariadb`,
	}
	ExecCmds(cmds)
}

func SyncFromPrimary(ip, user, pass string) {
	cmds := []string{
		`systemctl stop packetfence-iptables`,
		fmt.Sprintf(A3Root+`/bin/cluster/sync --from=%s`+
			`--api-user=%s --api-password=%s`, ip, user, pass),
		`systemctl restart packetfence-config`,
	}
	ExecCmds(cmds)
	waitProcStop("pfconfig")

	cmds = []string{
		pfcmd + "configreload",
		`systemctl set-default packetfence-cluster`,
		`rm -fr /var/lib/mysql/*`,
		`systemctl restart packetfence-mariadb`,
	}
	ExecCmds(cmds)
	waitProcStart("mysqld")
	/*
		cmds = []string{
			pfservice + "haproxy-db restart",
			pfservice + "httpd.webservices restart",
		}
		ExecCmds(cmds)
	*/
	ExecShell(pfservice + "pf start")
}

func RecoverDB() {
	cmds := []string{
		`systemctl restart packetfence-mariadb`,
	}

	ExecCmds(cmds)
}

func ServiceStatus() string {
	cmd := pfservice + "pf status"
	ret, _ := ExecShell(cmd)
	lines := strings.Split(ret, "\n")
	if len(lines) < 1 {
		return ""
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

	percent := strconv.Itoa((started + 1) * 100 / toBeStarted)
	return percent
}
