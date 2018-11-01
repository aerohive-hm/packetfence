package utils

import (
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/log"
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
	ExecShell(cmd, true)
}

func ReloadConfig() {
	pfExpire("all")
}

func restartPfconfig() (string, error) {
	cmd := `setsid sudo service packetfence-config restart 2>&1`
	return ExecShell(cmd, true)
}

func serviceCmdBackground(cmd string) (string, error) {

	str, err := ExecShell("setsid "+cmd+" &>/dev/null", true)
	ama.PfService = 100
	return str, err
}

func UpdatePfServices() []Clis {
	cmds := []string{
		pfcmd + "configreload hard",
		pfservice + "pf updatesystemd",
	}
	return ExecCmds(cmds)
}

func UpdateCurrentlyAt() {
	cmds := []string{
		"cp -f " + A3Release + " " + A3CurrentlyAt,
		"sync",
	}
	ExecCmds(cmds)
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
	ExecShell(`systemctl start packetfence-mariadb`, true)
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

	go serviceCmdBackground(pfservice + "pf start")
	log.LoggerWContext(ctx).Info("start Timer to check pf status")
	Timer(checkPfService, 12)

	return nil
}

func checkPfService() bool {
	var score int
	if ama.PfService == 100 {
		getPfServiceStop()
		goto END
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check pf status."))

	score = getServiceStartProc()
	if score < ama.PfService {
		return false
	}
	ama.PfService = score
	log.LoggerWContext(ctx).Info(fmt.Sprintf("update PfService = %d", score))
	if ama.PfService < 100 {
		return false
	}

END:
	if IsFileExist(A3CurrentlyAt) {
		return true
	}

	UpdateCurrentlyAt()
	//go ExecShell(`pfcmd service iptables restart`, true)
	return true
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
		`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat`,
		"systemctl start packetfence-mariadb",
	}
	ExecCmds(cmds)
	waitProcStart("mysqld")

	updateEtcd()

	cmds = []string{
		pfservice + "pf restart",
	}
	ExecCmds(cmds)
	ama.IsManagement = false

	log.LoggerWContext(ctx).Info(fmt.Sprintln("ForceNewCluster tasks done"))

	ama.SetClusterStatus(ama.Ready4Sync)
}

func UpdateDB() {
	cmds := []string{
		pfcmd + "configreload hard",
		pfcmd + "checkup",
		"systemctl stop packetfence-mariadb",
	}
	ExecCmds(cmds)
	waitProcStop("mysqld")

	cmds = []string{
		pfcmd + "generatemariadbconfig",
		"systemctl start packetfence-mariadb",
	}
	ExecCmds(cmds)
}

// prepare for the new cluster mode
func StopService() {
	cmds := []string{
		`systemctl stop packetfence-mariadb`,
		`systemctl stop packetfence-etcd`,
		`rm -rf /usr/local/pf/var/etcd/`,
		`pfcmd service httpd.webservices stop`,
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

	ExecShell(`systemctl start packetfence-config`, true)
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


func RestartKeepAlived() {
	cmds := []string{
		pfcmd + "configreload hard",
		pfservice + "keepalived restart",
	}
	ExecCmds(cmds)
	ama.IsManagement = false
}

func RemoveFromCluster() {
	cmds := []string{
		`systemctl stop packetfence-etcd`,
		`rm -rf /usr/local/pf/var/etcd/`,
	}

	ExecCmds(cmds)
}

type pfcallback func([]string) interface{}

func getPfSerStatus() []string {
	cmd := pfservice + "pf status"
	ret, _ := ExecShell(cmd, false)
	lines := strings.Split(ret, "\n")

	if len(lines) < 1 {
		return nil
	}
	return lines
}

func getServiceStartProc() int {
	toBeStarted := 0
	started := 0

	lines := getPfSerStatus()
	if lines == nil {
		return 0
	}

	for _, l := range lines {
		vals := strings.Fields(l)

		if len(vals) == 3 {
			if vals[1] == "started" {
				toBeStarted += 1
				started += 1
			} else if vals[1] == "stopped" {
				toBeStarted += 1
			}
		}
	}

	if toBeStarted > 0 {
		return started * 100 / toBeStarted
	} else {
		return 100
	}
}

func getPfServiceStop() {
	lines := getPfSerStatus()
	if lines == nil {
		return
	}

	for _, l := range lines {
		vals := strings.Fields(l)
		if len(vals) != 3 {
			return
		}

		if vals[1] != "stopped" {
			continue
		}
		re := regexp.MustCompile(`packetfence-([\w-]+)\.service`)
		ret := re.FindStringSubmatch(vals[0])
		log.LoggerWContext(ctx).Info(fmt.Sprintf("pf start failed: %s", ret[1]))
		ExecShell(fmt.Sprintf(`pfcmd service %s start`, ret[1]), false)
	}
}

func SyncFromMaster(file string) error {
	cmd := A3Root + `/bin/cluster/sync --as-master --file=` + file
	_, err := ExecShell(cmd, true)
	return err
}

func checkAndRestartNTPSync() {
	out, err := ExecShell(`timedatectl status`, false)
	if err != nil {
		return
	}

	re := regexp.MustCompile(`NTP synchronized: yes`)
	ret := re.FindAllStringSubmatch(out, -1)

	if len(ret) == 0 {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("NTP NOT synchronized, restart NTP"))
		cmds := []string{
			`timedatectl set-ntp false`,
			`timedatectl set-ntp true`,
		}
		ExecCmds(cmds)
	} else {
		if !ama.SystemNTPSynced {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("NTP already synchronized"))
		}
		ama.SystemNTPSynced = true
	}

	return
}

// Make sure NTP synchronized successfully, or else the admin account will have problem to login
func ForceNTPsynchronized() {
	ticker := time.NewTicker(time.Duration(30) * time.Second)
	defer ticker.Stop()
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check NTP synchronized status"))
	checkAndRestartNTPSync()
	if ama.SystemNTPSynced {
		return
	}

	for _ = range ticker.C {
		checkAndRestartNTPSync()
	}
}

func CheckAndStartOneService(name string)  {
	cmd := pfservice + name + " status"
	ret, _ := ExecShell(cmd, true)
	lines := strings.Split(ret, "\n")

	if len(lines) < 1 {
		return 
	}


	for _, l := range lines {
		vals := strings.Fields(l)

		if len(vals) == 3 {
			if vals[1] == "started" {
				log.LoggerWContext(ctx).Info(fmt.Sprintf("service %s is started, do nothing!!", name))
			} else if vals[1] == "stopped" {
				log.LoggerWContext(ctx).Info(fmt.Sprintf("service %s is not started, starting it!!", name))
				cmd = pfservice + name + " start"
				ExecShell(cmd, true)
				break
			}
		}
	}

	return

}
