// dbrecovery.go implements handling Mariadb recovery

package apibackend


import (
	"context"
	"fmt"
	"encoding/json"
	"time"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
)

var ctx = context.Background()



func GetPeerMariadbRecoveryData(ip string)  {
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/dbstatus", ip)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("get cluster MariaDB recovery data from %s", url))
	NodeData := event.MariadbNodeInfo{}
	
	client := new(apibackclient.Client)
	client.Host = ip

	err := client.ClusterSend("GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return 
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read node %s MariaDB recovery data:%s", ip, string(client.RespData)))

	err = json.Unmarshal(client.RespData, &NodeData)
	event.MariadbStatusData.OtherNode = append(event.MariadbStatusData.OtherNode, NodeData)

	return 
}



func SendMariadbRecoveryState(ip, State string) error {
	data := new(event.PostDbStatusData)

	data.State = State
	data.Code = "ok"
	data.SendIp = utils.GetOwnMGTIp()

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/dbstatus", ip)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Post MariaDB state change to %s", url))


	client := new(apibackclient.Client)
	client.Host = ip
	jsonData, err := json.Marshal(&data)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return err
	}

	err = client.ClusterSend("POST", url, string(jsonData))

	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
	}

	return err
}


func NotifyClusterBootStrapChange(state string) error {
	nodeList := a3config.ClusterNew().FetchNodesInfo()
	ownMgtIp := utils.GetOwnMGTIp()

	for _, node := range nodeList {
		if node.IpAddr == ownMgtIp {
			continue
		}

		err := SendMariadbRecoveryState(node.IpAddr, state)
		if err != nil {
			log.LoggerWContext(ctx).Error(fmt.Sprintln(err.Error()))
		}
	}

	return nil
}

func GetOtherNodesData() {

	event.MariadbStatusData.OtherNode = []event.MariadbNodeInfo{}
	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		if n.IpAddr == utils.GetOwnMGTIp() {
			continue
		}
		GetPeerMariadbRecoveryData(n.IpAddr)
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("current cluster MariaDB recovery data %v", event.MariadbStatusData))

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


func IhaveAllOtherNodeInfo() bool {

	nodes := a3config.ClusterNew().FetchNodesInfo()
	total := 0
	IhaveNodeCnt := 0
	for _, n := range nodes {
		total++
		if n.IpAddr == utils.GetOwnMGTIp() {
			IhaveNodeCnt++
			continue
		}
		for _, node := range event.MariadbStatusData.OtherNode {
			if node.IpAddr == n.IpAddr {
				IhaveNodeCnt++
				break
			}
		}
	}

	if IhaveNodeCnt != total {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("Don't have all nodes information, check it later"))
		return false
	}

	return true
}

// check if cluster have bootstrap node
func SafeToBootstrapNodeExist() bool {

	// Must fetch all nodes information then make the judgement
	if !IhaveAllOtherNodeInfo() {
		return true
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
	if !IhaveAllOtherNodeInfo() {
		return false
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
	if OtherNodeIsSafeToBootstrap {
		NotifyClusterBootStrapChange("YouAreNotSafeToBootstrap")
	}
	return true
}



// most advanced node exist or not 
func MostAdvancedNodeExist() bool {

	// Must fetch all nodes information then make the judgement
	if !IhaveAllOtherNodeInfo() {
		return true
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
	if !IhaveAllOtherNodeInfo() {
		return false
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


func MariadbStartNewCluster() bool {
	result, err := utils.ExecShell(`ps -ef | grep mysqld | grep -v grep | sed -n '/wsrep-new-cluster/ p'`, true)
	if err != nil {
		return false
	}
	
	if len(result) == 0 {
		return false
	}

	return true
}

//check mariadb_error.log
//add more case check later
func CheckMariadbErrorTCLOG() bool {
	result, _ := utils.ExecShell(`tail -n 50 /usr/local/pf/logs/mariadb_error.log | sed -n '/restart, or delete tc log and start mysqld with --tc-heuristic-recover/ p'`, true)

	if len(result) == 0 {
		return false
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check mariadb_error.log return=%s!!!", result))
	utils.ExecShell(`rm -fr /var/lib/mysql/tc.log`, true)
	return true
}


//check mariadb_error.log
//add more case check later
func CheckMariadbErrorAddressInUse() bool {
	result, _ := utils.ExecShell(`tail -n 50 /usr/local/pf/logs/mariadb_error.log|sed -n '/gcs connect failed: Address already in use/ p'`, true)
	if len(result) == 0 {
		return false
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check mariadb_error.log return=%s!!!", result))
	return true
}


//check mariadb_error.log
//add more case check later
func CheckMariadbErrorStateNotRecoverable() bool {
	result, _ := utils.ExecShell(`tail -n 50 /usr/local/pf/logs/mariadb_error.log|sed -n '/gcs connect failed: State not recoverable/ p'`, true)

	if len(result) == 0 {
		return false
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Check mariadb_error.log return=%s!!!", result))
	result, _ = utils.ExecShell(`cat /var/lib/mysql/gvwstate.dat`, true)
	
	if len(result) == 0 {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("empty file: /var/lib/mysql/gvwstate.dat, delete it!!!"))
		utils.ExecShell(`rm -fr /var/lib/mysql/gvwstate.dat`, true)
		
	}
	
	return false
}



//MairaDB is alive and healthy, restart some service that may failed to start
//The reason is when Mariadb is not active like bootup time, if Mariadb take a long time to go alive
//some service will fail to start and never restart again because systemd magic
func CheckServiceAndStart(){
	utils.CheckAndStartOneService("haproxy-portal")
	utils.CheckAndStartOneService("pfdns")
}


func CheckClusterDBHealthy() {
	alive := 0
	total := 0
	dbgoodCnt := 0


	if (event.MariadbStatusData.DBIsHealthy) {
		return
	}
	dbClusterList := amadb.QueryDBClusterIpSet()
	nodes := a3config.ClusterNew().FetchNodesInfo()
	for _, n := range nodes {
		total++
		if strings.Contains(dbClusterList, n.IpAddr) {
				alive++
		} 	
	}

	GetOtherNodesData()	
	
	if alive == total {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("Cluster MariaDB is healthy!!"))
		event.MariadbStatusData.DBIsHealthy = true
		CheckServiceAndStart()
		return
	} else {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("Cluster MariaDB is NOT healthy!!"))
		if !IamSafeToBootstrap() && MariadbStartNewCluster() {
			event.RestartMariadb(false)
		} else if IamSafeToBootstrap() && !MariadbStartNewCluster() {
			event.RestartMariadb(true)
		}
		return
	}
		

	for _, node := range event.MariadbStatusData.OtherNode {
		if node.DBState == event.MariadbGood {
			dbgoodCnt++
		}
	}

	if dbgoodCnt == total {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("cluster MariaDB are split-brain, my brain have %s, do something here!!!", dbClusterList))
		return
	}

}

func CheckErrorAndRestartProcess() bool {

	if CheckMariadbErrorTCLOG() || CheckMariadbErrorAddressInUse() || CheckMariadbErrorStateNotRecoverable() {
		return true
	}

	if event.MariadbIsNonPrimary() {
		return true
	}

	return false

}


// Only monitor Mariadb do right starting and modify related parameters
// But don't start or stop Mariadb here actively
func MariadbStatusCheck() {	
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Start Check MariaDB status Timer"))
	ticker := time.NewTicker(time.Duration(20) * time.Second)
	defer ticker.Stop()

	event.GetMyMariadbRecoveryData()
	GetOtherNodesData()

	for _ = range ticker.C {
		if !utils.IsFileExist(utils.A3CurrentlyAt) {
			continue
		}	

		if ama.IsClusterJoinMode() {
			continue
		}
		if event.MariadbIsActive() {
			if event.MariadbStatusData.DBState == event.MariadbFail {
				//I am good, reset those grastate data
				event.ResetGrastateData()
			}
			event.MariadbStatusData.DBState = event.MariadbGood
			if a3config.ClusterNew().CheckClusterEnable() && event.ClusterNodesCnt() > 1 {
				CheckClusterDBHealthy()
			}

			if !a3config.ClusterNew().CheckClusterEnable() {
				event.MariadbStatusData.DBIsHealthy = true 
			}
			continue
		} else {
			event.MariadbStatusData.DBState = event.MariadbFail
			event.GetMyMariadbRecoveryData()
			GetOtherNodesData()
	

			//mariadb not start yet or initial setup mode, do nothing now
			if !utils.IsProcAlive("mysqld")  {
				log.LoggerWContext(ctx).Info(fmt.Sprintf("mysqld process is not starting!!!"))
				continue
			}

			// Make sure I am doing right
			if IamSafeToBootstrap() {
				if CheckErrorAndRestartProcess() {
					event.RestartMariadb(true)
					continue
				}

				if HaveOtherNodeDbAvailiable() {
					event.RestartMariadb(false)
					continue
				}
				
				// do something if I am safe to bootstrap
				if !MariadbStartNewCluster() {
					event.RestartMariadb(true)
					continue
				}
				log.LoggerWContext(ctx).Info(fmt.Sprintf("I am safe_to_bootstrap, run mysqld with wsrep-new-cluster!!!"))
				
			} else {
			
				if CheckErrorAndRestartProcess() {
					event.RestartMariadb(false)
					continue
				}
				// I should not run with wsrep-new-cluster
				// change something to make it right
				if MariadbStartNewCluster() {
					event.RestartMariadb(false)
					continue
				}
				log.LoggerWContext(ctx).Info(fmt.Sprintf("I am NOT safe_to_bootstrap, run mysqld with normal!!!"))

				//Why I can't join, something wrong?
				if HaveOtherNodeDbAvailiable() {
					//TODO check mariadb-error.log to find some reason
					log.LoggerWContext(ctx).Info(fmt.Sprintf("Other node MariaDB is good, why I can't join, something wrong"))
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
				log.LoggerWContext(ctx).Info(fmt.Sprintf("I am most advanced node, run mysqld with wsrep-new-cluster!!!"))
				event.RestartMariadb(true)
			}

			//don't know who have most advance node, try me
			if !MostAdvancedNodeExist() {			
				NotifyClusterBootStrapChange("YouAreNotSafeToBootstrap")
				log.LoggerWContext(ctx).Info(fmt.Sprintf("I choose me as most advanced node, run mysqld with wsrep-new-cluster!!!"))
				event.RestartMariadb(true)
			}
		}
	}

}


