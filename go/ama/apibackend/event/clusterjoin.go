/*join.go implements handling REST API:
 *	/a3/api/v1/event/cluster/join
 */
package event

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
)

type Join struct {
	crud.Crud
}

func ClusterJoinNew(ctx context.Context) crud.SectionCmd {
	join := new(Join)
	join.New()
	join.Add("POST", handleUpdateEventClusterJoin)
	return join
}

func handleUpdateEventClusterJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	clusterData := new(a3config.ClusterEventJoinData)

	err := json.Unmarshal(d.ReqData, clusterData)
	if err != nil {
		return []byte(err.Error())
	}
	err, Respdata := a3config.UpdateEventClusterJoinData(ctx, *clusterData)
	if err != nil {
		return []byte(err.Error())
	}
	Resp, _ := json.Marshal(Respdata)
	return []byte(Resp)
}
