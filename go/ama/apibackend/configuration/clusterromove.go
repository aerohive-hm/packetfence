//cluster.go implements handling REST API:
//
//  /a3/api/v1/configuration/cluster/remove



package configuration

import (
	"context"
	"net/http"
	"encoding/json"
	"fmt"
	
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"

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

	err := json.Unmarshal(d.ReqData, removeData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error: " + err.Error())
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Try to remove cluster node = %s", removeData.Hostname))

	//If the removing node is myself, POST remove event to other node to do for me
	if removeData.Hostname == utils.GetHostname() {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("Try to remove myself, notify other node to take action for me"))
		//TODO
	}

	
	//remove other nodes

	//remove node configuration from cluster.conf

	//notify other nodes to stopService

	// force-new-cluster process

	//notify other nodes to startSync

	
	code = "ok"
	return crud.FormPostRely(code, retMsg)
}
