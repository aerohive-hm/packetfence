/*sync.go implements handling REST API:
 *	/a3/api/v1/event/cluster/sync
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type Sync struct {
	crud.Crud
}

func ClusterSyncNew(ctx context.Context) crud.SectionCmd {
	sync := new(Sync)
	sync.New()
	sync.Add("GET", handleGetSync)
	sync.Add("POST", handleUpdateSync)
	return sync
}

// get status of primary server
func handleGetSync(r *http.Request, d crud.HandlerData) []byte {
	t := ama.ClusterStatus

	if !t.IsPrimary {
		return []byte(`{"code":"fail", "msg":"not a primary server."}`)
	}

	var s string
	switch {
	case t.Status == ama.PrepareSync:
		s = a3share.StopService
	case t.Status == ama.Ready4Sync:
		s = a3share.StartSync
	case t.Status == ama.FinishSync:
		s = a3share.FinishSync
	default:
		s = "unknown status"
	}
	return []byte(fmt.Sprintf(`{"code":"ok", "status":"%s", "ip":"%s"}`, s, utils.GetOwnMGTIp()))
}

func handleUpdateSync(r *http.Request, d crud.HandlerData) []byte {
	var ctx = context.Background()
	sync := new(a3share.SyncData)
	code := "ok"
	ret := ""

	err := json.Unmarshal(d.ReqData, sync)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive sync %s from %s", sync.Status, sync.SendIp))
	switch {
	case sync.Status == a3share.StopService:
		//primary tell slave node to stop service
		//but POST from primary to slave node is not work
		if ama.IsClusterJoinMode() {
			code = "fail"
			ret = "already in cluster join"
		} else {		
			utils.StopService()
			ama.SetClusterStatus(ama.PrepareSync)
		}
	case sync.Status == a3share.StartSync:
		//primary tell slave node to start sync
		ip := sync.SendIp
		web := a3config.GetWebServices()["webservices"]
		utils.SyncFromPrimary(ip, web["user"], web["pass"])
		utils.ExecShell(utils.A3Root + "/bin/pfcmd service pf restart")

		a3share.SendClusterSync(ip, a3share.FinishSync)
		ama.ClearClusterStatus()
	case sync.Status == a3share.FinishSync:
		//slave node notify primary to sync completed
		ama.UpdateClusterNodeStatus(sync.SendIp, ama.SyncFinished)
		if ama.IsAllNodeStatus(ama.SyncFinished) {
			utils.RecoverDB()
			ama.ClearClusterStatus()
		}
	case sync.Status == a3share.ServerRemoved:
		utils.RemoveFromCluster()
	case sync.Status == a3share.UpdateConf:
		utils.RestartKeepAlived()
	default:
		code = "fail"
		ret = "Unkown status."
	}

	return crud.FormPostRely(code, ret)
}
