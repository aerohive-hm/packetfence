// dbrecovery.go implements handling Mariadb recovery

package apibackend


import (
	"context"
	"fmt"
	"encoding/json"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
)


// Query DB status
func MariadbIsActive() bool {
	ctx := context.Background()
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
	ctx := context.Background()
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
func SafeToBootstrapNodeExist() bool {
	ctx := context.Background()

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
			log.LoggerWContext(ctx).Info(fmt.Sprintf("node %s has seqno=%d and it is safe_to_bootstrap node", event.MariadbStatusData.GrastateSeqno, node.GrastateSeqno, node.IpAddr))
			return true
		}
	}

	log.LoggerWContext(ctx).Error(fmt.Sprintf("none of nodes is safe_to_bootstrap node"))
	return false
}


// check if I am safe_to_boostraper or not
// 1: check safe_to_boostraper
// 2: compare seqno
// 3: use gvwstate.bat
func IamSafeToBootstrap() bool {
	ctx := context.Background()
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



// suppose none of nodes have safe_to_bootstrap, when call this function
func IamMostAdvancedNode() bool {
	ctx := context.Background()

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
	ctx := context.Background()
	utils.ExecShell(`(ps -ef | grep mysqld | grep -v grep | awk '{print $2}' | xargs kill -9) &>/dev/null`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA Killed Mariadb!!!"))
}


func MariadbStartNewCluster() bool {
	ctx := context.Background()
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

func ModifygrastateFileSafeToBootstrap() {
	ctx := context.Background()
	utils.ExecShell(`sed -i 's/^safe_to_bootstrap.*$/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA modify safe_to_bootstrap=1 for /var/lib/mysql/grastate.dat!!!"))
}



func RecoveryStartedMariadb() {
	ctx := context.Background()
	utils.ExecShell(`systemctl start packetfence-mariadb.service`)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("AMA Starting Mariadb!!!"))
}

// Make sure NTP synchronized successfully, or else the admin account will have problem to login
func MariadbStatusCheck() {
	ctx := context.Background()
	interval := 20
	count := 0
	if !utils.IsFileExist(utils.A3CurrentlyAt) {
		return
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Start Check Mariadb status Timer"))
	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	defer ticker.Stop()

	for _ = range ticker.C {
		count++
		if MariadbIsActive() {
			event.MariadbStatusData.DBState = event.MariadbGood
		} else {
			event.MariadbStatusData.DBState = event.MariadbFail
			event.GetMyMariadbRecoveryData()
			GetOtherNodesData()

			// do something if I am safe to bootstrap
			if IamSafeToBootstrap() {
				if !MariadbStartNewCluster() {
					KillMysqld()
					ModifygrastateFileSafeToBootstrap()
					RecoveryStartedMariadb()
					continue
				}
			} else {
				if MariadbStartNewCluster() {
					KillMysqld()
					RecoveryStartedMariadb()
					continue
				}
			}

			//we have node that can safe to bootstrap, do nothing
			if SafeToBootstrapNodeExist() {
				continue
			}

			if IamMostAdvancedNode() {
				KillMysqld()
				ModifygrastateFileSafeToBootstrap()
				RecoveryStartedMariadb()
			}
			// print log each 1 min
			if count % 6 == 0 {
				log.LoggerWContext(ctx).Info(fmt.Sprintf("Mariadb is not active"))
			}
		}
	}
}


