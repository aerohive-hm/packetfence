//amastatus.go implements handling REST API:
/*
 *      /a3/api/v1/event/ama/status
 */
package event

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/log"
	"net/http"
	"encoding/json"
	"fmt"
)

type AMAStatus struct {
	Hostname     string `json:"hostname"`
	SystemID     string `json:"systemID"`
	Status       string `json:"status"`
	LastConnTime string `json:"lastConnectTime"`
}

type Status struct {
	crud.Crud
}

func AMAStatusNew(ctx context.Context) crud.SectionCmd {
	status := new(Status)
	status.New()
	status.Add("GET", handleGetAMAStatus)
	return status
}

func handleGetAMAStatus(r *http.Request, d crud.HandlerData) []byte {
	var ctx = r.Context()
	amaStatus := AMAStatus{}

	amaStatus.Hostname = a3config.GetHostname()
	amaStatus.SystemID = utils.GetA3SysId()
	amaStatus.Status = amac.GetAMAConnStatus()
	amaStatus.LastConnTime = fmt.Sprintf("%v", amac.ReadLastConTime())

	jsonData, err := json.Marshal(amaStatus)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
