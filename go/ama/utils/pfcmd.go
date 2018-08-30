package utils

import (
	//"errors"
	"fmt"
	//"regexp"
	"github.com/inverse-inc/packetfence/go/log"
	"strconv"
	"strings"
	"time"
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

func UpdatePfServices() (string, error) {
	cmd := pfservice + "pf updatesystemd"
	return ExecShell(cmd)
}

func updateCurrentlyAt() {
	cmd := "cp -f " + A3Release + " " + A3CurrentlyAt
	ExecShell(cmd)
}
func initClusterDB() {
	clis := []Clis{
		{
			cmd: pfcmd + "configreload hard",
		},
		{
			cmd: pfcmd + "checkup",
		},
		{
			cmd: `systemctl set-default packetfence-cluster`,
		},
		{
			cmd: `systemctl stop packetfence-mariadb`,
		},
		{
			cmd: pfcmd + "generatemariadbconfig",
		},
		{
			cmd: A3Root + `/sbin/pf-mariadb --force-new-cluster &`,
		},
	}

	ExecClis(clis)
}

// only Start Services during initial setup
func InitStartService() error {
	out, err := UpdatePfServices()
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	out, err = restartPfconfig()
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	time.Sleep(time.Duration(15) * time.Second)
	go initClusterDB()
	time.Sleep(time.Duration(15) * time.Second)

	out, err = serviceCmdBackground(pfservice + "pf start")
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	updateCurrentlyAt()
	return nil
}

func ForceNewCluster() {
	clis := []Clis{
		{
			cmd: pfcmd + "configreload hard",
		},
		{
			cmd: pfcmd + "checkup",
		},
		{
			cmd: "systemctl stop packetfence-mariadb",
		},
		{
			cmd: pfcmd + "generatemariadbconfig",
		},
		{
			cmd: A3Root + `/sbin/pf-mariadb --force-new-cluster &`,
		},
	}

	ExecClis(clis)
}

func SyncFromPrimary(ip, user, pass string) {
	clis := []Clis{
		{
			cmd: `systemctl stop packetfence-iptables`,
		},
		{
			cmd: fmt.Sprintf(A3Root+`/bin/cluster/sync --from=%s`+
				`--api-user=%s --api-password=%s`, ip, user, pass),
		},
		{
			cmd: `systemctl restart packetfence-config`,
		},
		{
			cmd: pfcmd + "configreload",
		},
		{
			cmd: `systemctl set-default packetfence-cluster`,
		},
		{
			cmd: `rm -fr /var/lib/mysql/*`,
		},
		{
			cmd: `systemctl restart packetfence-mariadb`,
		},
		{
			cmd: pfservice + "haproxy-db restart",
		},
		{
			cmd: pfservice + "httpd.webservices restart",
		},
	}

	ExecClis(clis)
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

	percent := strconv.Itoa((started + 1) * 100 / (started + toBeStarted))
	return percent
}
