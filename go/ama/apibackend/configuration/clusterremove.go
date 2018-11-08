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
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/database"
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

func getIpByHost(hostname []string) map[string]string {
	nodes := a3config.ClusterNew().FetchNodesInfo()
	ips := make(map[string]string)

	for _, h := range hostname {
		ip := ""
		for _, n := range nodes {
			if h == n.Hostname {
				ip = n.IpAddr
				break
			}
		}

		if ip == "" {
			continue
		}
		ips[h] = ip
	}
	return ips
}

// remove Cluster server on local
func removeServerOnLocal(hostname []string) bool {

	ama.InitClusterStatus("primary")

	nodes := a3config.ClusterNew().FetchNodesInfoHash()

	var ips []string
	for _, h := range hostname {
		ip := ""
		ip, ok := nodes[h]
		if !ok {
			ama.ClearClusterStatus()
			return false
		}

		ips = append(ips, ip)
		/*delete sysid by hostname in db*/
		amadb.DeleteSysIdbyHost(h)
	}
	if ips == nil {
		ama.ClearClusterStatus()
		return false
	}

	for _, ip := range ips {
		a3share.SendClusterSync(ip, a3share.ServerRemoved)
	}
	//remove node configuration from cluster.conf
	a3config.RemoveClusterServer(hostname)

	return true
}

// sync cluster remove to members
func syncRemove2Other(ctx context.Context, sysids []string) {
	//remove other nodes
	//notify other nodes to stopService
	ret := a3share.NotifyClusterStatus(a3share.StopService)
	for ip, err := range ret {
		if err != nil {
			log.LoggerWContext(ctx).Info(fmt.Sprintf("fail to get response from %s", ip))
			// ToDo: add rollback recovery
		}
	}

	// force-new-cluster process
	nodes := a3config.ClusterNew().FetchNodesInfo()
	if len(nodes) > 1 {
		utils.ForceNewCluster()
		//notify other nodes to startSync
		a3share.NotifyClusterStatus(a3share.StartSync)
	} else {
		utils.UpdateDB()
	}

	//notify cloud server removed in cluster
	amac.UpdateMsgToRdcSyn(ctx, amac.RemoveNodeFromCluster, sysids)

	ama.ClearClusterStatus()
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
	var sysids []string
	var ret map[string]error
	var ips map[string]string
	var ip string
	var foundIp bool

	err := json.Unmarshal(d.ReqData, removeData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error: " + err.Error())
		retMsg = err.Error()
		goto END
	}

	if len(removeData.Hostname) == 0 {
		retMsg = "No hostname specified!."
		goto END
	}

	if ama.IsClusterJoinMode() {
		retMsg = "The server is removing another cluster, please wait for a moment."
		goto END
	}
	//check if all cluster nodes are alive or not
	ips = getIpByHost(removeData.Hostname)
	ret = a3share.NotifyClusterStatus(a3share.NotifySync)
	for ip, err = range ret {
		if err == nil {
			continue
		}

		foundIp = false
		for _, v := range ips {
			if v == ip {
				foundIp = true
				break
			}
		}

		if !foundIp {
			log.LoggerWContext(ctx).Info(fmt.Sprintln(err.Error()))
			retMsg = "Some of the members are offline."
			goto END
		}
	}
	//If the removing node is myself, POST remove event to other node to do for me
	hostname = utils.GetHostname()
	for _, h := range removeData.Hostname {
		if h != hostname {
			/*fetch sysid from db by hostname*/
			id := amadb.QuerySysIdbyHost(h)
			sysids = append(sysids, id)
			continue
		}

		log.LoggerWContext(ctx).Info(fmt.Sprintf("Try to remove myself, " +
			"login another server to do remove."))
		retMsg = "Try to remove self, login another server to do remove."
		goto END
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Try to remove cluster node = %v", removeData.Hostname))
	rc = removeServerOnLocal(removeData.Hostname)
	if !rc {
		retMsg = "Invalid hostname"
		goto END
	}
	go syncRemove2Other(ctx, sysids)
	code = "ok"
END:
	return crud.FormPostRely(code, retMsg)
}
