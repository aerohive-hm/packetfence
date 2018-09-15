//cluster.go implements handling REST API:
//
//  /a3/api/v1/configuration/cluster/remove

package configuration

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	//"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterRemove struct {
	crud.Crud
}

func ClusterRemoveNew(ctx context.Context) crud.SectionCmd {
	cluster := new(ClusterRemove)
	cluster.New()
	cluster.Add("GET", handleGetClusterRemove)
	cluster.Add("POST", handlePostClusterRemove)
	return cluster
}

func handleGetClusterRemove(r *http.Request, d crud.HandlerData) []byte {
	return nil
}

// remove Cluster server on local
func removeServerOnLocal(hostname []string) bool {

	ama.InitClusterStatus("primary")

	nodes := a3config.ClusterNew().FetchNodesInfo()

	var ips []string
	for _, h := range hostname {
		ip := ""
		for _, n := range nodes {
			if h == n.Hostname {
				ip = n.IpAddr
				break
			}
		}

		if ip == "" {
			ama.ClearClusterStatus()
			return false
		}
		ips = append(ips, ip)
	}

	for _, ip := range ips {
		a3share.SendClusterSync(ip, a3share.ServerRemoved)
	}
	//remove node configuration from cluster.conf
	a3config.RemoveClusterServer(hostname)
	return true
}

// sync cluster remove to members
func syncRemove2Other(ctx context.Context) {
	//remove other nodes
	//notify other nodes to stopService
	err := a3share.NotifyClusterStatus(a3share.StopService)
	if err != nil {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("post event sync to stopService failed"))
		return
	}

	// force-new-cluster process
	utils.ForceNewCluster()

	//notify other nodes to startSync
	a3share.NotifyClusterStatus(a3share.StartSync)

	//notify cloud server removed in cluster
	//amac.UpdateMsgToRdcSyn(ctx, amac.RemoveNodeFromCluster)

}

// Send by the UI to remove a node from cluster on UI
// POST /a3/api/v1/configuration/cluster/remove to carry hostname for removing
//  "hostname":"a3_node2.aerohive.com"
// If the removed node is self, notify another server to be primary and remove me
// POST /a3/api/v1/event/cluster/remove to carry hostname data
//  "hostname":"a3_node2.aerohive.com"
func handlePostClusterRemove(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	removeData := new(a3config.ClusterRemoveData)
	code := "fail"
	retMsg := ""
	var rc bool
	var hostname string

	err := json.Unmarshal(d.ReqData, removeData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error: " + err.Error())
		retMsg = err.Error()
		goto END
	}

	if ama.IsClusterJoinMode() {
		retMsg = "another server is joining the cluster."
		goto END
	}

	//If the removing node is myself, POST remove event to other node to do for me
	hostname = utils.GetHostname()
	for _, h := range removeData.Hostname {
		if h != hostname {
			continue
		}

		log.LoggerWContext(ctx).Info(fmt.Sprintf("Try to remove myself, " +
			"logon another server to do remove."))
		retMsg = "Try to remove self, logon another server to do remove."
		goto END
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Try to remove cluster node = %s", removeData.Hostname))
	rc = removeServerOnLocal(removeData.Hostname)
	if !rc {
		retMsg = "invalid hostname"
		goto END
	}
	go syncRemove2Other(ctx)
	code = "ok"
END:
	return crud.FormPostRely(code, retMsg)
}
