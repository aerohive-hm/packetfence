//cluster.go implements handling REST API:
//  /a3/api/v1/configuration/cluster

package configuration

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type Status struct {
	crud.Crud
}

func StatusNew(ctx context.Context) crud.SectionCmd {
	status := new(Status)
	status.New()
	status.Add("GET", handleGetClusterStatus)
	return status
}

func handleGetClusterStatus(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	StatusData := a3config.GetClusterStatus(ctx)

	jsonData, err := json.Marshal(StatusData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
