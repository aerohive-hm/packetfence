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
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type SyncData struct {
	Code   string `json:"code"`
	Status string `json:"status"`
	SendIp string `json:"ip"`
}

type Sync struct {
	crud.Crud
}

const (
	stopService      = "StopServices"
	startSync        = "StartSync"
	finishSync       = "FinishSync"
	primaryRecovered = "PrimaryRecovered"
)

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
	if t.Status == ama.PrepareSync {
		s = stopService
	} else if t.Status == ama.Ready4Sync {
		s = startSync
	} else if t.Status == ama.FinishSync {
		s = finishSync
	}
	return []byte(fmt.Sprintf(`{"code":"ok", "status":"%s", "ip":"%s"}`, s, utils.GetOwnMGTIp()))
}

func handleUpdateSync(r *http.Request, d crud.HandlerData) []byte {
	var ctx = context.Background()
	sync := new(SyncData)
	code := "ok"
	ret := ""

	err := json.Unmarshal(d.ReqData, sync)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive sync %s from %s", sync.Status, sync.SendIp))
	if sync.Status == stopService {
		//primary tell slave node to stop service
		//but POST from primary to slave node is not work
		utils.StopService()
	} else if sync.Status == startSync {
		//primary tell slave node to start sync
		//ip, _, _ := net.SplitHostPort(r.RemoteAddr)
		ip := sync.SendIp
		web := a3config.GetWebServices()["webservices"]
		utils.SyncFromPrimary(ip, web["user"], web["pass"])
		utils.ExecShell(utils.A3Root + "/bin/pfcmd service pf restart")

		//amac.JoinCompleteEvent()
		apibackclient.SendClusterSync(ip, "FinishSync")
	} else if sync.Status == finishSync {
		//slave node notify primary to sync completed
		//TODO: need all node completed
		ama.SetClusterStatus(ama.FinishSync)
		utils.RecoverDB()
	} else {
		code = "fail"
		ret = "Unkown status."
	}

	return crud.FormPostRely(code, ret)
}
