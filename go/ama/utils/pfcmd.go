package utils

import (
	//"errors"
	"fmt"
	//"regexp"
	"github.com/inverse-inc/packetfence/go/ama"
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
		pfcmd + "configreload hard",
		pfservice + "pf updatesystemd",
	}
	return ExecCmds(cmds)
}

func UpdateCurrentlyAt() {
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
		`systemctl start packetfence-mariadb`,
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
func InitStartService(isCluster bool) error {
	UpdatePfServices()

	out, err := restartPfconfig()
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	waitProcStart("pfconfig")
	if isCluster {
		initClusterDB()
	} else {
		initStandAloneDb()
	}
	waitProcStart("mysqld")

	out, err = serviceCmdBackground(pfservice + "pf start")
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintln(out))
	}

	//TODO: need to restart http server? abort web service?
	//cmds := []string{
	//	pfservice + "httpd.admin restart",
	//}
	//ExecCmds(cmds)

	return nil
}

func ForceNewCluster() {
	cmds := []string{
		pfcmd + "configreload hard",
		pfcmd + "checkup",
		"systemctl stop packetfence-mariadb",
	}
	ExecCmds(cmds)
	waitProcStop("mysqld")

	cmds = []string{
		pfcmd + "generatemariadbconfig",
		A3Root + `/sbin/pf-mariadb --force-new-cluster &>/dev/null &`,
	}
	ExecCmds(cmds)
	waitProcStart("mysqld")

	updateEtcd()

	cmds = []string{
		pfservice + "pf restart",
	}
	ExecCmds(cmds)

	log.LoggerWContext(ctx).Info(fmt.Sprintln("ForceNewCluster tasks done"))

	ama.SetClusterStatus(ama.Ready4Sync)
}

// prepare for the new cluster mode
func StopService() {
	cmds := []string{
		`systemctl stop packetfence-mariadb`,
		`systemctl stop packetfence-etcd`,
		`rm -rf /usr/local/pf/var/etcd/`,
	}
	ExecCmds(cmds)
}

func SyncFromPrimary(ip, user, pass string) {
	ama.SetClusterStatus(ama.SyncFiles)
	cmds := []string{
		`systemctl stop packetfence-iptables`,
		`systemctl stop packetfence-mariadb`,
	}
	ExecCmds(cmds)
	waitProcStop("mysqld")

	cmds = []string{
		fmt.Sprintf(A3Root+`/bin/cluster/sync --from=%s `+
			`--api-user=%s --api-password=%s`, ip, user, pass),
		`systemctl stop packetfence-config`,
	}
	ExecCmds(cmds)
	waitProcStop("pfconfig")

	ExecShell(`systemctl start packetfence-config`)
	waitProcStart("pfconfig")

	ama.SetClusterStatus(ama.SyncDB)
	cmds = []string{
		pfcmd + "configreload hard",
		pfservice + "haproxy-db restart",
		pfservice + "httpd.webservices restart",
		`systemctl set-default packetfence-cluster`,
		`rm -fr /var/lib/mysql/*`,
		`systemctl start packetfence-mariadb`,
	}
	ExecCmds(cmds)
	waitProcStart("mysqld")
	ama.SetClusterStatus(ama.SyncFinished)
}

func RecoverDB() {
	killPorc("pf-mariadb")
	cmds := []string{
		`systemctl restart packetfence-mariadb`,
		//pfservice + "pf restart",
	}

	ExecCmds(cmds)
}

func RestartKeepAlived() {
	ExecShell(pfservice + "keepalived restart")
}

func RemoveFromCluster() {
	cmds := []string{
		"rm -f " + A3Root + "/conf/cluster.pf",
		`systemctl stop packetfence-etcd`,
		`rm -rf /usr/local/pf/var/etcd/`,
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

func SyncFromMaster(file string) error {
	cmd := A3Root + `/bin/cluster/sync --as-master --file=` + file
	_, err := ExecShell(cmd)
	return err
}
