//cluster.go implements handling REST API:
//  /a3/api/v1/configuration/cluster

package configuration

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type Cluster struct {
	crud.Crud
}

func ClusterNew(ctx context.Context) crud.SectionCmd {
	cluster := new(Cluster)
	cluster.New()
	cluster.Add("GET", handleGetClusterInfo)
	cluster.Add("POST", handlePostClusterInfo)
	return cluster
}

func handleGetClusterInfo(r *http.Request, d crud.HandlerData) []byte {

	ctx := r.Context()

	clusterInfoData := new(a3config.ClusterInfoData)

	GetClusterInfoData(ctx, clusterInfoData)

	jsonData, err := json.Marshal(clusterInfoData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Marshal error:" + err.Error())
		return []byte(err.Error())
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusterInfoData))
	return jsonData
}

func restartService() {
	//restart keepalived service
	utils.RestartKeepAlived()
	//notify other node sync configuration and restart keepalived
	utils.SyncFromMaster(utils.A3Root + `/conf/pf.conf`)
	a3share.NotifyClusterStatus(a3share.UpdateConf)
}

func handlePostClusterInfo(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	infoData := new(a3config.ClusterInfoData)
	code := "fail"
	retMsg := ""

	err := json.Unmarshal(d.ReqData, infoData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error: " + err.Error())
		retMsg = err.Error()
		goto END
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", infoData))
	if infoData.RouterId == "" || infoData.SharedKey == "" {
		retMsg = "wrong post data!"
		goto END
	}
	// save configuration
	err = UpdateClusterInfoData(ctx, infoData)
	if err != nil {
		retMsg = err.Error()
		goto END
	}

	go restartService()

	code = "ok"
END:
	return crud.FormPostRely(code, retMsg)
}

func GetClusterInfoData(ctx context.Context, clusterdata *a3config.ClusterInfoData) {

	// Get shared key and virtual router ID

	aaCfg := a3config.A3ReadFull("PF", "active_active")["active_active"]
	clusterdata.SharedKey = aaCfg["password"]
	clusterdata.RouterId = aaCfg["virtual_router_id"]

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read from configuration sharedKey=%s, routeID=%s",
		clusterdata.SharedKey, clusterdata.RouterId))

	// Get cluster node Information
	conf := a3config.ClusterNew()
	nodeList := conf.FetchNodesInfo()
	ownMgtIp := utils.GetOwnMGTIp()

	clusterdata.Ifaces = conf.GetClusterVips()

	dbClusterList := amadb.QueryDBClusterIpSet()

	for _, node := range nodeList {
		clusterNode := new(a3config.ClusterNodeItem)
		if node.IpAddr == ownMgtIp {
			clusterNode.NodeType = "Master"
			clusterNode.Status = "Active"
		} else {
			clusterNode.NodeType = "Member"
			if strings.Contains(dbClusterList, node.IpAddr) {
				clusterNode.Status = "Active" //get from DB
			} else {
				clusterNode.Status = "Inactive"
			}
		}
		clusterNode.Hostname = node.Hostname
		clusterNode.IpAddr = node.IpAddr

		clusterdata.Nodes = append(clusterdata.Nodes, *clusterNode)
	}

	return
}

func UpdateClusterInfoData(ctx context.Context, clusterInfo *a3config.ClusterInfoData) error {

	// what will we need to do when cluster/shared key change

	log.LoggerWContext(ctx).Info(fmt.Sprintf("ClusterInfoData %v", clusterInfo))

	section := a3config.Section{
		"active_active": {
			"password":          clusterInfo.SharedKey,
			"virtual_router_id": clusterInfo.RouterId,
		},
	}
	return a3config.A3Commit("PF", section)
}
