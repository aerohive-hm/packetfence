/*sync.go implements handling REST API:
 *	/a3/api/v1/event/cluster/sync
 */
package event

import (
	"context"
	"encoding/json"
	//"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	//"github.com/inverse-inc/packetfence/go/log"
)

type SyncData struct {
	Status string `json:"status"`
}

type Sync struct {
	crud.Crud
}

const (
	stopService = "StopServices"
	startSync   = "StartSync"
	finishSync  = "FinishSync"
)

func ClusterSyncNew(ctx context.Context) crud.SectionCmd {
	sync := new(Sync)
	sync.New()
	sync.Add("POST", handleUpdateSync)
	return sync
}

func handleUpdateSync(r *http.Request, d crud.HandlerData) []byte {
	sync := new(SyncData)
	code := "ok"
	ret := ""

	err := json.Unmarshal(d.ReqData, sync)
	if err != nil {
		return []byte(err.Error())
	}

	if sync.Status == stopService {
		utils.StopService()
	} else if sync.Status == startSync {
		ip := a3config.ReadClusterPrimary()
		web := a3config.GetWebServices()["webservices"]
		utils.SyncFromPrimary(ip, web["user"], web["pass"])
	} else if sync.Status == finishSync {
		utils.RecoverDB()
	} else {
		code = "fail"
		ret = "Unkown status."
	}

	return crud.FormPostRely(code, ret)
}
