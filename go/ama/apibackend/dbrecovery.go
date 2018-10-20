// dbrecovery.go implements handling Mariadb recovery

package apibackend


import (
	"context"
	"fmt"
	"encoding/json"
	"time"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
)

var ctx = context.Background()

// Query DB status
func MariadbIsActive() bool {	
	sql := []amadb.SqlCmd{
		{
			Sql: `show status like 'wsrep_cluster_status'`,
		},
	}
	db := new(amadb.A3Db)	
	err := db.Exec(sql)
	if err != nil {
		log.LoggerWContext(ctx).Error("access db error: " + err.Error())
		return false
	}
	return true
}


func GetPeerMariadbRecoveryData(ip string)  {
	updateOtherNode := false
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/dbstatus", ip)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("get cluster mariadb recovery data from %s", url))
	NodeData := event.MariadbNodeInfo{}
	
	client := new(apibackclient.Client)
	client.Host = ip

	err := client.ClusterSend("GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return 
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read mariadb recovery data:%s",
		string(client.RespData)))

	err = json.Unmarshal(client.RespData, &NodeData)


	for _, node := range event.MariadbStatusData.OtherNode {
		if node.IpAddr == NodeData.IpAddr {
			node = NodeData	
			updateOtherNode = true
			break
		}
	}


	if !updateOtherNode {
		event.MariadbStatusData.OtherNode = append(event.MariadbStatusData.OtherNode, NodeData)
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("My store mariadb recovery data %v", event.MariadbStatusData))
	
	// GET status from all peer nodes
	return 
}

func GetOtherNodesData() {

	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		if n.IpAddr == utils.GetOwnMGTIp() {
			continue
		}
		GetPeerMariadbRecoveryData(n.IpAddr)
	}

}


// check if cluster have bootstrap node
func HaveOtherNodeDbAvailiable() bool {

	for _, node := range event.MariadbStatusData.OtherNode {
		if node.DBState == event.MariadbGood {
			return true
		}
	}

	return false
}

// check if cluster have bootstrap node
func SafeToBootstrapNodeExist() bool {

	// Must fetch all nodes information then make the judgement
	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		haveNodeInfo := false
		if n.IpAddr == utils.GetOwnMGTIp() {
			continue
		}
		for _, node := range event.MariadbStatusData.OtherNode {
			if node.IpAddr == n.IpAddr {
				haveNodeInfo = true
				break
			}
		}
		if !haveNodeInfo {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("Don't have all nodes information, suppose we have safe_to_bootstrap node, check it later"))
			return true
		}
	}

	
	if event.MariadbStatusData.SafeToBootstrap == 1 {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("my seqno=%d, I am safe_to_bootstrap", event.MariadbStatusData.GrastateSeqno))
		return true
	}

	for _, node := range event.MariadbStatusData.OtherNode {
		if node.SafeToBootstrap == 1 {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("node %s has seqno=%d and it is safe_to_bootstrap node", node.IpAddr, node.GrastateSeqno))
			return true
		}
	}

	//need to do something here??
	log.LoggerWContext(ctx).Error(fmt.Sprintf("none of nodes is safe_to_bootstrap node"))
	return false
}


// check if I am safe_to_boostraper or not
// 1: check safe_to_boostraper
// 2: compare seqno
// 3: use gvwstate.bat
func IamSafeToBootstrap() bool {
	OtherNodeIsSafeToBootstrap := false

	// Must fetch all nodes information then make the judgement
	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		haveNodeInfo := false
		if n.IpAddr == utils.GetOwnMGTIp() {
			continue
		}
		for _, node := range event.MariadbStatusData.OtherNode {
			if node.IpAddr == n.IpAddr {
				haveNodeInfo = true
				break
			}
		}
		if !haveNodeInfo {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("Don't have all nodes information, check it later"))
			return false
		}
	}

	if event.MariadbStatusData.SafeToBootstrap != 1 {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("my seqno=%d, I am not safe_to_bootstrap", event.MariadbStatusData.GrastateSeqno))
		return false
	}

	for _, node := range event.MariadbStatusData.OtherNode {
		if node.SafeToBootstrap == 1 {
			OtherNodeIsSafeToBootstrap = true
			break
		}
	}
	//not sure the case happen or not, just in case
	if OtherNodeIsSafeToBootstrap {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("more than one node have safe_to_bootstrap=1, need to check I am most advanced state or not"))
		
		for _, node := range event.MariadbStatusData.OtherNode {
			if event.MariadbStatusData.GrastateSeqno < node.GrastateSeqno {
				log.LoggerWContext(ctx).Info(fmt.Sprintf("my seqno=%d, %s seqno=%d, I am not safe_to_bootstrap", event.MariadbStatusData.GrastateSeqno, node.GrastateSeqno, node.IpAddr))
				return false
			}
		}


		//have same seqno, check gvwstate.dat info
		if event.MariadbStatusData.MyUUID != "" && event.MariadbStatusData.MyUUID == event.MariadbStatusData.ViewID {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("I have same my_uuid and view_id, I am safe_to_bootstrap"))
			return true
		}

		for _, node := range event.MariadbStatusData.OtherNode {
			if node.MyUUID != "" && node.MyUUID == node.ViewID {
				log.LoggerWContext(ctx).Info(fmt.Sprintf("%s have same my_uuid and view_id, I am not safe_to_bootstrap", node.IpAddr))
				return false
			}
		}
	}


	log.LoggerWContext(ctx).Info(fmt.Sprintf("my seqno=%d, I am safe_to_bootstrap", event.MariadbStatusData.GrastateSeqno))
	return true
}



// most advanced node exist or not 
func MostAdvancedNodeExist() bool {

	// Must fetch all nodes information then make the judgement
	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		haveNodeInfo := false
		if n.IpAddr == utils.GetOwnMGTIp() {
			continue
		}
		for _, node := range event.MariadbStatusData.OtherNode {
			if node.IpAddr == n.IpAddr {
				haveNodeInfo = true
				break
			}
		}
		if !haveNodeInfo {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("Don't have all nodes information, check it later"))
			return true
		}
	}
	


	for _, node := range event.MariadbStatusData.OtherNode {
		if node.MyUUID != "" && node.MyUUID == node.ViewID {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("%s is most advanced node, I am not", node.IpAddr))
			return true
		}
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("none of nodes is most advanced node"))
	return false
}


// suppose none of nodes have safe_to_bootstrap, when call this function
func IamMostAdvancedNode() bool {

	// Must fetch all nodes information then make the judgement
	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		haveNodeInfo := false
		if n.IpAddr == utils.GetOwnMGTIp() {
			continue
		}
		for _, node := range event.MariadbStatusData.OtherNode {
			if node.IpAddr == n.IpAddr {
				haveNodeInfo = true
				break
			}
		}
		if !haveNodeInfo {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("Don't have all nodes information, check it later"))
			return false
		}
	}
	
	for _, node := range event.MariadbStatusData.OtherNode {
		if node.GrastateSeqno != -1 && node.GrastateSeqno > event.MariadbStatusData.GrastateSeqno {
			return false
		}
	}

	if event.MariadbStatusData.GrastateSeqno > 0 {
		return true 
	}

	// all nodes have seqno = -1 and no safe_to_bootstrap
	if event.MariadbStatusData.MyUUID != "" && event.MariadbStatusData.MyUUID == event.MariadbStatusData.ViewID {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("I have same my_uuid and view_id, I am most advanced node"))
		return true
	}

	for _, node := range event.MariadbStatusData.OtherNode {
		if node.MyUUID != "" && node.MyUUID == node.ViewID {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("%s is most advanced node, I am not", node.IpAddr))
			return false
		}
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("I am not most advanced node"))
	return false
}

func KillMysqld() {
	utils.ExecShell(`(ps -ef | grep mysqld | grep -v grep | awk '{print $2}' | xargs kill -9) &>/dev/null`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA Killed Mariadb!!!"))
}

//check if mysqld already start
func MysqldIsExisted() bool {
	result, _ := utils.ExecShell(`ps -ef | grep mysqld | grep -v grep`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check mysqld exist or not return=%s!!!", result))
	if len(result) == 0 {
		return false
	}
	return true
}

func MariadbStartNewCluster() bool {
	result, err := utils.ExecShell(`ps -ef | grep mysqld | grep -v grep | sed -n '/wsrep-new-cluster/ p'`)
	if err != nil {
		return false
	}
	
	log.LoggerWContext(ctx).Info(fmt.Sprintf("find wsrep-new-cluster return=%s!!!", result))
	if len(result) == 0 {
		return false
	}

	return true
}

//check mariadb_error.log
//add more case check later
func CheckMariadbErrorTCLOG() bool {
	result, _ := utils.ExecShell(`tail -n 50 /usr/local/pf/logs/mariadb_error.log | sed -n '/restart, or delete tc log and start mysqld with --tc-heuristic-recover/ p'`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check mariadb_error.log return=%s!!!", result))
	if len(result) == 0 {
		return false
	}
	utils.ExecShell(`rm -fr /var/lib/mysql/tc.log`)
	return true
}


//check mariadb_error.log
//add more case check later
func CheckMariadbErrorAddressInUse() bool {
	result, _ := utils.ExecShell(`tail -n 50 /usr/local/pf/logs/mariadb_error.log|sed -n '/gcs connect failed: Address already in use/ p'`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check mariadb_error.log return=%s!!!", result))
	if len(result) == 0 {
		return false
	}
	return true
}


func ModifygrastateFileSafeToBootstrap() {
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat`)
	event.MariadbStatusData.SafeToBootstrap = 1
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=1 for /var/lib/mysql/grastate.dat!!!"))
}

func ModifygrastateFileNotSafeToBootstrap() {
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 0/' /var/lib/mysql/grastate.dat`)
	event.MariadbStatusData.SafeToBootstrap = 0
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=0 for /var/lib/mysql/grastate.dat!!!"))
}



func RecoveryStartedMariadb() {
	utils.ExecShell(`systemctl start packetfence-mariadb.service`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA Starting Mariadb!!!"))
}



func RestartMariadb(safeToBootstrap bool) {
	KillMysqld()
	if safeToBootstrap {
		ModifygrastateFileSafeToBootstrap()
	} else {
		ModifygrastateFileNotSafeToBootstrap()
	}
	RecoveryStartedMariadb()
}

// Only monitor Mariadb do right starting and modify related parameters
// But don't start or stop Mariadb here actively
func MariadbStatusCheck() {	
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Start Check Mariadb status Timer"))
	ticker := time.NewTicker(time.Duration(20) * time.Second)
	defer ticker.Stop()

	event.GetMyMariadbRecoveryData()
	GetOtherNodesData()

	for _ = range ticker.C {
		if !utils.IsFileExist(utils.A3CurrentlyAt) {
			continue
		}
		if MariadbIsActive() {
			if event.MariadbStatusData.DBState == event.MariadbFail {
				//I am good, reset those grastate data
				event.ResetGrastateData()
			}
			event.MariadbStatusData.DBState = event.MariadbGood
			
			continue
		} else {
			event.MariadbStatusData.DBState = event.MariadbFail
			event.GetMyMariadbRecoveryData()
			GetOtherNodesData()

			//mariadb not start yet or initial setup mode, do nothing now
			if ama.IsClusterJoinMode() || !MysqldIsExisted()  {
				continue
			}

			// Make sure I am doing right
			if IamSafeToBootstrap() {
				if CheckMariadbErrorTCLOG() || CheckMariadbErrorAddressInUse() {
					RestartMariadb(true)
					continue
				}

				if HaveOtherNodeDbAvailiable() {
					RestartMariadb(false)
					continue
				}
				
				// do something if I am safe to bootstrap
				if !MariadbStartNewCluster() {
					RestartMariadb(true)
					continue
				}
				
			} else {
			
				if CheckMariadbErrorTCLOG() || CheckMariadbErrorAddressInUse() {
					RestartMariadb(false)
					continue
				}
				// I should not run with wsrep-new-cluster
				// change something to make it right
				if MariadbStartNewCluster() {
					RestartMariadb(false)
					continue
				}

				//Why I can't join, something wrong?
				if HaveOtherNodeDbAvailiable() {
					//TODO check mariadb-error.log to find some reason
					log.LoggerWContext(ctx).Info(fmt.Sprintf("Other node mariadb is good, Why I can't join, something wrong"))
					continue
					
				}
			}

			
			// If I am doing right, wait other node doing right
			//we have node that can safe to bootstrap, do nothing now
			if SafeToBootstrapNodeExist() {
				continue
			}

			// All nodes doing right, still not work, pick one as master
			if IamMostAdvancedNode() {
				RestartMariadb(true)
			}

			//don't know who have most advance node, try me
			if !MostAdvancedNodeExist() {
				ModifygrastateFileSafeToBootstrap()
			}
		}
	}

}


